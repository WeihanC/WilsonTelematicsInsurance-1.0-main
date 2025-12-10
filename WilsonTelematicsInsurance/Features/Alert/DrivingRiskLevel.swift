//
//  DrivingRiskLevel.swift
//  WilsonTelematicsInsurance
//

import Foundation
import SwiftUI
import AudioToolbox
import UIKit

// MARK: - 风险等级

enum DrivingRiskLevel {
    case none
    case mild
    case medium
    case severe
    
    var displayText: String {
        switch self {
        case .none:   return "安全"
        case .mild:   return "轻微风险"
        case .medium: return "中度风险"
        case .severe: return "严重风险"
        }
    }

    var color: Color {
        switch self {
        case .none:   return .green
        case .mild:   return .yellow
        case .medium: return .orange
        case .severe: return .red
        }
    }
}

// MARK: - 提醒模型 & 实时样本

struct DrivingAlert: Identifiable, Equatable {
    let id = UUID()
    let time: Date
    let level: DrivingRiskLevel
    let title: String
    let message: String
}

/// 实时采样数据（位置 / 速度），主要用于以后做“基于限速的超速判断”
/// 目前因为还拿不到限速，所以只作为背景信息
struct LiveDrivingSample {
    let timestamp: Date
    let speedMps: Double
    let speedLimitMps: Double?
    let accelMps2: Double?
    let isHarshBrakingEvent: Bool
    let isHarshAccelEvent: Bool
}

// MARK: - 实时提醒引擎

@MainActor
class DrivingAlertManager: ObservableObject {

    static let shared = DrivingAlertManager()
    
    // 对 UI 暴露
    @Published var currentRiskLevel: DrivingRiskLevel = .none
    @Published var alerts: [DrivingAlert] = []
    @Published var activeAlert: DrivingAlert? = nil

    // 超速参数（目前限速为 nil 时不会触发）
    private let mildOverspeedThresholdMph: Double = 5
    private let mediumOverspeedThresholdMph: Double = 10
    private let severeOverspeedThresholdMph: Double = 20
    private let mediumOverspeedDurationSec: TimeInterval = 18
    private let mediumOverspeedCooldownSec: TimeInterval = 60
    private let severeAccelThreshold: Double = 3.0
    private let harshBrakeWindowSec: TimeInterval = 30

    private var currentOverspeedStart: Date?
    private var recentOverspeedEvents: [Date] = []
    private var recentHarshBrakings: [Date] = []
    private var lastMediumAlertAt: Date?
    private var lastSevereAlertAt: Date?
    
    // 用于“事件智能化”的辅助状态
    private var lastSpeedMph: Double?
    private var lastEventAt: Date?
    private var lastEventTypeKey: String?

    // MARK: - 实时采样入口（位置 / 速度）

    func process(sample: LiveDrivingSample) {
        let now = sample.timestamp
        let speedMph = sample.speedMps * 2.23694
        lastSpeedMph = speedMph

        let overspeedMph = computeOverspeedMph(sample: sample)

        updateOverspeedState(overspeedMph: overspeedMph, now: now)

        if sample.isHarshBrakingEvent {
            recentHarshBrakings.append(now)
            cleanupHarshBrakings(now: now)
        }

        evaluateAndAlert(
            sample: sample,
            overspeedMph: overspeedMph,
            isSpeedRisingOrHigh: false, // 先不做复杂速度趋势判断
            now: now
        )
    }

    // MARK: - 超速（目前限速为 nil 时完全关闭）

    private func computeOverspeedMph(sample: LiveDrivingSample) -> Double {
        let speedMph = sample.speedMps * 2.23694
        
        // ❗️关键：拿不到限速时直接认为 overspeed = 0 → 不触发任何超速逻辑
        guard let limitMps = sample.speedLimitMps else {
            return 0
        }
        let limitMph = limitMps * 2.23694
        return max(0, speedMph - limitMph)
    }

    private func updateOverspeedState(overspeedMph: Double, now: Date) {
        if overspeedMph > 0 {
            if currentOverspeedStart == nil {
                currentOverspeedStart = now
            }
            if overspeedMph >= mediumOverspeedThresholdMph {
                recentOverspeedEvents.append(now)
            }
        } else {
            currentOverspeedStart = nil
        }

        let oneMinAgo = now.addingTimeInterval(-60)
        recentOverspeedEvents = recentOverspeedEvents.filter { $0 >= oneMinAgo }
    }

    private func cleanupHarshBrakings(now: Date) {
        let windowStart = now.addingTimeInterval(-harshBrakeWindowSec)
        recentHarshBrakings = recentHarshBrakings.filter { $0 >= windowStart }
    }

    private func evaluateAndAlert(
        sample: LiveDrivingSample,
        overspeedMph: Double,
        isSpeedRisingOrHigh: Bool,
        now: Date
    ) {
        let risk = classifyRisk(
            sample: sample,
            overspeedMph: overspeedMph,
            isSpeedRisingOrHigh: isSpeedRisingOrHigh,
            now: now
        )

        currentRiskLevel = risk

        switch risk {
        case .none, .mild:
            break
        case .medium:
            if canTriggerMediumAlert(now: now) {
                recentOverspeedEvents.append(now)
                triggerMediumAlert(reason: "持续超速 / 轻微危险驾驶", now: now)
                lastMediumAlertAt = now
            }
        case .severe:
            if canTriggerSevereAlert(now: now) {
                recentOverspeedEvents.append(now)
                triggerSevereAlert(reason: "严重超速或危险驾驶", now: now)
                lastSevereAlertAt = now
            }
        }
    }

    private func classifyRisk(
        sample: LiveDrivingSample,
        overspeedMph: Double,
        isSpeedRisingOrHigh: Bool,
        now: Date
    ) -> DrivingRiskLevel {

        let accel = abs(sample.accelMps2 ?? 0)
        cleanupHarshBrakings(now: now)

        if overspeedMph >= severeOverspeedThresholdMph ||
            accel >= severeAccelThreshold ||
            recentHarshBrakings.count >= 2 {
            return .severe
        }

        if overspeedMph >= mediumOverspeedThresholdMph,
           let start = currentOverspeedStart {
            let duration = now.timeIntervalSince(start)
            let hadRecentOverspeed = recentOverspeedEvents.count >= 1

            if duration >= mediumOverspeedDurationSec &&
                hadRecentOverspeed &&
                isSpeedRisingOrHigh {
                return .medium
            }
        }

        if overspeedMph >= mildOverspeedThresholdMph ||
            accel >= 1.5 ||
            sample.isHarshBrakingEvent ||
            sample.isHarshAccelEvent {
            return .mild
        }

        return .none
    }

    private func canTriggerMediumAlert(now: Date) -> Bool {
        guard let last = lastMediumAlertAt else { return true }
        return now.timeIntervalSince(last) >= mediumOverspeedCooldownSec
    }

    private func canTriggerSevereAlert(now: Date) -> Bool {
        guard let last = lastSevereAlertAt else { return true }
        return now.timeIntervalSince(last) >= 20
    }

    // MARK: - 从 SDK “事件” 直接触发提醒（主角）

    /// Damoov SDK `onNewEvents` 里调用
    func handleSDKEvent(type: String, timestamp: Date = Date()) {
        let lower = type.lowercased()
        let speed = lastSpeedMph ?? 0
        
        // 1) 速度太低直接忽略（比如停车场里挪车）
        guard speed > 5 else { return }

        // 2) 去抖动：同一种事件 5 秒内只提醒一次
        let key = lower
        if let lastType = lastEventTypeKey,
           let lastTime = lastEventAt,
           lastType == key,
           timestamp.timeIntervalSince(lastTime) < 5 {
            return
        }
        lastEventTypeKey = key
        lastEventAt = timestamp

        // 3) 根据速度分级：低速 Mild，中速 Medium，高速 Severe
        var level: DrivingRiskLevel = .mild
        var title = "驾驶行为提醒"
        var message = "检测到驾驶行为事件：\(type)"

        func classify(bySpeedForBaseSevere: Bool) -> DrivingRiskLevel {
            if speed < 20 {          // 城市低速
                return .mild
            } else if speed < 40 {   // 一般道路
                return .medium
            } else {                 // 高速 / 快速路
                return bySpeedForBaseSevere ? .severe : .medium
            }
        }

        if lower.contains("brak") {
            level = classify(bySpeedForBaseSevere: true)
            title = "急刹车提醒"
            message = "检测到急刹车行为，请注意与前车保持安全距离。"
        } else if lower.contains("accel") {
            level = classify(bySpeedForBaseSevere: true)
            title = "急加速提醒"
            message = "检测到急加速行为，请保持平稳驾驶。"
        } else if lower.contains("corner") {
            level = classify(bySpeedForBaseSevere: false)
            title = "急转弯提醒"
            message = "检测到急转弯行为，请减速通过弯道。"
        }

        currentRiskLevel = level
        triggerHaptic(for: level)

        let alert = DrivingAlert(
            time: timestamp,
            level: level,
            title: title,
            message: message
        )
        pushAlert(alert)

        // 一段时间后自动把“当前风险等级”降回安全
        scheduleRiskReset()
    }

    // MARK: - UI 反馈：震动 + banner（你已经在 AlertView 里实现）

    private func triggerMediumAlert(reason: String, now: Date) {
        triggerHaptic(for: .medium)
        let alert = DrivingAlert(
            time: now,
            level: .medium,
            title: "中度风险提醒",
            message: reason
        )
        pushAlert(alert)
        scheduleRiskReset()
    }

    private func triggerSevereAlert(reason: String, now: Date) {
        triggerHaptic(for: .severe)
        let alert = DrivingAlert(
            time: now,
            level: .severe,
            title: "严重风险提醒",
            message: reason
        )
        pushAlert(alert)
        scheduleRiskReset()
    }

    /// 把 Alert 插入列表，并让 AlertView 的 popup 弹出来
    private func pushAlert(_ alert: DrivingAlert) {
        alerts.insert(alert, at: 0)
        activeAlert = alert
    }

    /// 不再播放语音，只做震动 / Haptic
    private func triggerHaptic(for level: DrivingRiskLevel) {
        let generator = UINotificationFeedbackGenerator()
        switch level {
        case .mild:
            generator.notificationOccurred(.success)   // 轻一点
        case .medium:
            generator.notificationOccurred(.warning)
        case .severe:
            generator.notificationOccurred(.error)
            // 想要更强震动可以再加一行：
            // AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        case .none:
            break
        }
    }

    /// 比如 20 秒内没有新的事件，就把风险等级恢复成“安全”
    private func scheduleRiskReset() {
        let current = Date()
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 20 * 1_000_000_000)
            // 如果 20 秒内没有新的事件，才真正重置
            if let last = lastEventAt, Date().timeIntervalSince(last) >= 20 {
                currentRiskLevel = .none
            }
        }
    }
}

// MARK: - 调试用：AlertView 里的“测试严重提醒”按钮调用

extension DrivingAlertManager {
    func debugTriggerSevereEvent() {
        handleSDKEvent(type: "harsh_braking_debug")
    }
}
