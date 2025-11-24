//
//  AppDelegate.swift
//  WilsonTelematicsInsurance
//

import UIKit
import FirebaseCore
import TelematicsSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // 1️⃣ 初始化 Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured (in AppDelegate)")

        // 2️⃣ 初始化 Damoov SDK (必须在 AppDelegate)
        RPEntry.initializeSDK()
        print("🚀 RPEntry.initializeSDK() called")

        // ❌ 这里不要再恢复 telematics（必须经过 Firebase 登录）
        // 恢复逻辑已经由 AuthViewModel 自动处理

        return true
    }
}
