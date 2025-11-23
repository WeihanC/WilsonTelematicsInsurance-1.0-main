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
        print("🚀 App launched")
        
        // CRITICAL: Initialize SDK first before accessing RPEntry.instance
        RPEntry.initializeSDK()
        
        // Note: Device token should be set after user authentication
        // For development/testing, you can set a test token here:
        // let testToken = "YOUR_TEST_DEVICE_TOKEN"
        // RPEntry.instance.virtualDeviceToken = testToken
        // RPEntry.instance.setEnableSdk(true)
        
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
