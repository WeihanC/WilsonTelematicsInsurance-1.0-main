//
//  AppDelegate.swift
//  WilsonTelematicsInsurance
//
//  全局 AppDelegate：
//  1. 初始化 Firebase
//  2. 初始化 Damoov Telematics SDK
//  3. 作为 RPLocationDelegate 接收实时位置 & 事件
//  4. 把位置数据转成 LiveDrivingSample → TelematicsService → DrivingAlertManager
//

import UIKit
import FirebaseCore
import TelematicsSDK
import CoreLocation

class AppDelegate: NSObject, UIApplicationDelegate, RPLocationDelegate {

    // MARK: - UIApplicationDelegate

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // 1️⃣ 初始化 Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured (in AppDelegate)")

        // 2️⃣ 初始化 Damoov Telematics SDK（必须在 didFinishLaunching 中调用）
        RPEntry.initializeSDK()
        print("🚀 RPEntry.initializeSDK() called")

        // 3️⃣ 通知 SDK：App 启动完成（部分文档示例会转发这个）
        let options = launchOptions ?? [:]
        RPEntry.instance.application(application, didFinishLaunchingWithOptions: options)

        // 4️⃣ 订阅 SDK 的位置 & 事件回调
        RPEntry.instance.locationDelegate = self
        print("📡 RPLocationDelegate attached to RPEntry.instance")

        // ⚠️ 不要在这里恢复/登录 telematics，登录逻辑在 AuthViewModel / TelematicsService.configure 里处理
        return true
    }

    // App 进入后台
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("📲 App did enter background")
        RPEntry.instance.applicationDidEnterBackground(application)
    }

    // App 回到前台（但还没 active）
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("📲 App will enter foreground")
        RPEntry.instance.applicationWillEnterForeground(application)
    }

    // App 变为 active 状态
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("📲 App did become active")
        RPEntry.instance.applicationDidBecomeActive(application)
    }

    // 后台抓取（如果 SDK 需要后台刷新，会用到）
    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        RPEntry.instance.application(application) {
            completionHandler(.newData)
        }
    }

    // MARK: - RPLocationDelegate

    /// SDK 每次位置更新都会回调这里（频率取决于 SDK 内部逻辑与设置）
    func onLocationChanged(_ location: CLLocation) {
        // CoreLocation: speed < 0 代表无效数据
        let rawSpeed = location.speed
        let speedMps = rawSpeed > 0 ? rawSpeed : 0
        let speedMph = speedMps * 2.23694

        print("📍 onLocationChanged — lat:\(location.coordinate.latitude), lon:\(location.coordinate.longitude), speed = \(speedMps) m/s (\(speedMph) mph)")

        // 目前拿不到限速 & 加速度，就先传 nil
        // DrivingAlertManager 里会用固定限速（测试阶段你可以设成 40 mph 等）
        Task { @MainActor in
            TelematicsService.shared.handleRealtimeSample(
                speedMps: speedMps,
                speedLimitMps: nil,   // TODO: 以后接入真实限速数据时填入
                accelMps2: nil,       // TODO: 以后接入纵向加速度数据时填入
                isHarshBrake: false,  // 事件由 onNewEvents 单独处理
                isHarshAccel: false
            )
        }
    }

    /// SDK 检测到事件（急刹、急加速、转弯等）会回调这里
    ///
    /// 这里我们：
    ///   1. 打印事件，方便你在 Xcode console 里观察原始结构
    ///   2. 把事件类型映射到 DrivingAlertManager，触发 UI Alert / 震动提醒
    func onNewEvents(_ events: [RPEventPoint]) {
        guard !events.isEmpty else { return }

        print("🎯 onNewEvents — count = \(events.count)")

        for event in events {
            // 原始事件整体打印一份，方便调试
            print("    raw event = \(event)")

            // 根据 Damoov iOS 示例，RPEventPoint 有一个 type 字段
            let type = event.type ?? "unknown"

            print("    → SDK event type = \(type)")

            // 把事件类型交给 DrivingAlertManager（单例）
            Task { @MainActor in
                DrivingAlertManager.shared.handleSDKEvent(type: type)
            }
        }
    }
}
