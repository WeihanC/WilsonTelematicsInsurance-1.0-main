//
//  AppDelegate.swift
//  WilsonTelematicsInsurance
//
//  App layer: Application delegate for SDK initialization
//

import UIKit
import TelematicsSDK

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // 1. 初始化 SDK（必须最早调用）
        RPEntry.initializeSDK()

        // 2. 把 AppDelegate 事件转给 SDK
        let options = launchOptions ?? [:]
        RPEntry.instance.application(application, didFinishLaunchingWithOptions: options)

        // 可选：低电量、精度不足的 delegate 将来再加
        return true
    }

    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("🌅 App entering foreground")
        TelematicsService.shared.applicationWillEnterForeground()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("🌙 App entering background")
        TelematicsService.shared.applicationDidEnterBackground()
    }
}
