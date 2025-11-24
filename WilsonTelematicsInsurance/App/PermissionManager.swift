//
//  PermissionManager.swift
//  WilsonTelematicsInsurance
//

import Foundation
import CoreLocation
import CoreMotion

@MainActor
final class PermissionManager: NSObject, ObservableObject {

    static let shared = PermissionManager()

    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionActivityManager()

    @Published private(set) var locationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var motionAuthorized: Bool = false

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    /// 一次性请求「始终定位 + 运动与健身」权限
    func requestAllPermissions() {
        // 1. 定位权限
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            // 直接请求 Always，系统会自动先给 When In Use，再引导升级
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedWhenInUse {
            // 已经有前台权限，可以再请求 Always
            locationManager.requestAlwaysAuthorization()
        }

        // 2. 运动与健身权限（通过一次假的 query 触发系统弹框）
        if CMMotionActivityManager.authorizationStatus() == .notDetermined {
            let now = Date()
            motionManager.queryActivityStarting(from: now,
                                                to: now,
                                                to: .main) { _, error in
                if error == nil {
                    self.motionAuthorized = true
                } else {
                    self.motionAuthorized = false
                }
            }
        } else {
            motionAuthorized = (CMMotionActivityManager.authorizationStatus() == .authorized)
        }
    }

    /// 简单检查是否“看起来都授权了”
    func hasAllPermissions() -> Bool {
        let loc = CLLocationManager.authorizationStatus()
        let locOK: Bool = {
            switch loc {
            case .authorizedAlways: return true
            case .authorizedWhenInUse: return true   // 先这样，之后可以引导升级 Always
            default: return false
            }
        }()

        let motionOK = (CMMotionActivityManager.authorizationStatus() == .authorized)

        return locOK && motionOK
    }
}

extension PermissionManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print("📍 Location authorization changed: \(status.rawValue)")
    }
}
