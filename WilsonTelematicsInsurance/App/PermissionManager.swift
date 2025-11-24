//
//  PermissionManager.swift
//  WilsonTelematicsInsurance
//

import Foundation
import CoreLocation
import CoreMotion

final class PermissionManager: NSObject, CLLocationManagerDelegate {

    static let shared = PermissionManager()

    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionActivityManager()

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    // MARK: - 单独请求 Location 权限

    func requestLocationPermission() {
        // 如果还没请求过，建议直接要 Always（后台行程才靠谱）
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - 单独请求 Motion & Fitness 权限

    func requestMotionPermission() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            print("⚠️ Motion Activity not available on this device")
            return
        }

        // 这是苹果官方推荐的触发权限弹窗的方式：做一次假的 query
        let now = Date()
        motionManager.queryActivityStarting(from: now,
                                            to: now,
                                            to: .main) { _, _ in
            // 没有实际数据，只是触发授权流程
        }
    }

    // MARK: - 检查权限是否都 OK

    func hasAllPermissions() -> Bool {
        let locStatus = locationManager.authorizationStatus
        let motionStatus = CMMotionActivityManager.authorizationStatus()

        let locationOK = (locStatus == .authorizedAlways || locStatus == .authorizedWhenInUse)
        let motionOK = (motionStatus == .authorized)

        return locationOK && motionOK
    }

    // MARK: - 调试用 delegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("📍 Location auth changed: \(manager.authorizationStatus.rawValue)")
    }
}
