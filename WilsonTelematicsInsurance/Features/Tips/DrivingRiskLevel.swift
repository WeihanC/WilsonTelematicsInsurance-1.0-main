import Foundation
import AVFoundation

/// 风险等级
enum DrivingRiskLevel {
    case none
    case mild
    case medium
    case severe
}

/// 实时采样数据（你之后从 Damoov SDK / CoreMotion 填充）
struct LiveDrivingSample {
    let timestamp: Date
    let speedMps: Double           // 当前车速（m/s）
    let speedLimitMps: Double?     // 限速（m/s），如果暂时拿不到就先传 nil
    let accelMps2: Double?         // 纵向加速度（m/s²），可选
    let isHarshBrakingEvent: Bool  // SDK 回调到一次急刹事件时置 true
    let isHarshAccelEvent: Bool    // 急加速事件
}

/// 实时提醒引擎
@MainActor
class DrivingAlertManager: ObservableObject {

    // MARK: - 可调阈值（以后你可以做成设置页里让用户自定义）
    private let mildOverspeedThresholdMph: Double = 5          // 轻微：> 限速+5
    private let mediumOverspeedThresholdMph: Double = 10       // 中度：> 限速+10
    private let severeOverspeedThresholdMph: Double = 20       // 严重：> 限速+20

    private let mediumOverspeedDurationSec: TimeInterval = 18  // 15–20 秒中间值
    private let mediumOverspeedCooldownSec: TimeInterval = 60  // 中度提醒冷却 1 分钟

    private let severeAccelThreshold: Double = 3.0             // |a| >= 3 m/s²

    private let harshBrakeWindowSec: TimeInterval = 30         // 30 秒窗口

    // MARK: - 状态缓存

    /// 最近一段时间的「超速开始时间」，用来判断持续超速
    private var currentOverspeedStart: Date?

    /// 最近 1 分钟内发生的「中度以上」超速事件时间，用于叠加判断
    private var recentOverspeedEvents: [Date] = []

    /// 最近 30 秒内急刹时间
    private var recentHarshBrakings: [Date] = []

    /// 上一次中度提醒时间（冷却用）
    private var lastMediumAlertAt: Date?

    /// 上一次严重提醒时间（你也可以给严重单独冷却，比如 20–30 秒）
    private var lastSevereAlertAt: Date?

    /// 语音合成器
    private let speech = AVSpeechSynthesizer()

    // MARK: - 对外入口：每次有新的实时数据就喂一条进来

    func process(sample: LiveDrivingSample) {
        let now = sample.timestamp

        // 1. 计算超速程度（mph）
        let overspeedMph = computeOverspeedMph(sample: sample)

        // 2. 更新超速持续时间 / 最近超速事件列表
        updateOverspeedState(overspeedMph: overspeedMph, now: now)

        // 3. 更新急刹记录
        if sample.isHarshBrakingEvent {
            recentHarshBrakings.append(now)
            cleanupHarshBrakings(now: now)
        }

        // 4. 判定风险等级 & 是否触发提醒
        evaluateAndAlert(
            sample: sample,
            overspeedMph: overspeedMph,
            now: now
        )
    }

    // MARK: - 超速计算 & 状态更新

    private func computeOverspeedMph(sample: LiveDrivingSample) -> Double {
        let speedMph = sample.speedMps * 2.23694
        guard let limitMps = sample.speedLimitMps else {
            // 如果暂时没有限速，可以先用固定阈值，例如 > 75 mph 当作超速
            let fixedLimitMph: Double = 75
            return max(0, speedMph - fixedLimitMph)
        }
        let limitMph = limitMps * 2.23694
        return max(0, speedMph - limitMph)
    }

    private func updateOverspeedState(overspeedMph: Double, now: Date) {
        if overspeedMph > 0 {
            // 正在超速
            if currentOverspeedStart == nil {
                currentOverspeedStart = now
            }
        } else {
            // 没有超速，把 currentOverspeedStart 清掉
            currentOverspeedStart = nil
        }

        // 清理 1 分钟之前的记录
        let oneMinAgo = now.addingTimeInterval(-60)
        recentOverspeedEvents = recentOverspeedEvents.filter { $0 >= oneMinAgo }
    }

    private func cleanupHarshBrakings(now: Date) {
        let windowStart = now.addingTimeInterval(-harshBrakeWindowSec)
        recentHarshBrakings = recentHarshBrakings.filter { $0 >= windowStart }
    }

    // MARK: - 核心判定逻辑

    private func evaluateAndAlert(
        sample: LiveDrivingSample,
        overspeedMph: Double,
        now: Date
    ) {
        let risk = classifyRisk(sample: sample, overspeedMph: overspeedMph, now: now)

        switch risk {
        case .none, .mild:
            // 轻微违规只记账，不提醒
            break

        case .medium:
            if canTriggerMediumAlert(now: now) {
                recentOverspeedEvents.append(now)
                triggerMediumAlert(overspeedMph: overspeedMph)
                lastMediumAlertAt = now
            }

        case .severe:
            if canTriggerSevereAlert(now: now) {
                recentOverspeedEvents.append(now)
                triggerSevereAlert(overspeedMph: overspeedMph)
                lastSevereAlertAt = now

                // TODO: 在这里记一条“严重事件”，供保费模型使用
                // PricingModel.shared.recordSevereEvent(...)
            }
        }
    }

    // 风险分类
    private func classifyRisk(
        sample: LiveDrivingSample,
        overspeedMph: Double,
        now: Date
    ) -> DrivingRiskLevel {

        // 1) 严重：超速 >= 20 mph，或 |a| >= 3 m/s²，或 30 秒 2 次以上急刹
        let accel = abs(sample.accelMps2 ?? 0)
        cleanupHarshBrakings(now: now)

        if overspeedMph >= severeOverspeedThresholdMph ||
            accel >= severeAccelThreshold ||
            recentHarshBrakings.count >= 2 {
            return .severe
        }

        // 2) 中度：持续超速 >= 10 mph & 持续时间 >= 18 秒 & 最近 1 分钟已发生 ≥1 次事件
        if overspeedMph >= mediumOverspeedThresholdMph,
           let start = currentOverspeedStart {
            let duration = now.timeIntervalSince(start)
            let hadRecentOverspeed = recentOverspeedEvents.count >= 1

            if duration >= mediumOverspeedDurationSec && hadRecentOverspeed {
                return .medium
            }
        }

        // 3) 轻微：只要轻微超速 / 一次急刹（但没达到 severe 条件）
        if overspeedMph >= mildOverspeedThresholdMph ||
            accel >= 1.5 ||
            sample.isHarshBrakingEvent ||
            sample.isHarshAccelEvent {
            return .mild
        }

        return .none
    }

    // MARK: - 冷却判断

    private func canTriggerMediumAlert(now: Date) -> Bool {
        guard let last = lastMediumAlertAt else { return true }
        return now.timeIntervalSince(last) >= mediumOverspeedCooldownSec
    }

    private func canTriggerSevereAlert(now: Date) -> Bool {
        // 严重可以给得稍微频一点，比如 20 秒一次
        guard let last = lastSevereAlertAt else { return true }
        return now.timeIntervalSince(last) >= 20
    }

    // MARK: - 播放提醒（短提示音 + 语音）

    private func triggerMediumAlert(overspeedMph: Double) {
        playBeep()
        speak(text: "注意，您已经连续超速，请减速行驶。")
        print("⚠️ Medium alert: overspeed +\(overspeedMph) mph")
    }

    private func triggerSevereAlert(overspeedMph: Double) {
        playBeep()
        playBeep()
        speak(text: "危险驾驶！请立即减速，并避免急加速或急刹车。")
        print("🚨 Severe alert: overspeed +\(overspeedMph) mph")
    }

    private func playBeep() {
        // 这里先用系统声音占位，你可以以后换成自己 bundle 里的音效
        AudioServicesPlaySystemSound(1057)  // “收到消息”那种短提示音
    }

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.48
        speech.speak(utterance)
    }
}
