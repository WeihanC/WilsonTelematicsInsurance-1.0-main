//
//  TelematicsService.swift
//  WilsonTelematicsInsurance
//
//  Core layer: Service to interact with Telematics SDK
//

import Foundation
import TelematicsSDK
import Combine

/// Service class to manage telematics SDK operations
@MainActor
class TelematicsService: ObservableObject {

    static let shared = TelematicsService()
    
    // MARK: - Published state for UI

    /// SDK 是否已经配置好（即已经拿到 deviceToken 并设置到 RPEntry）
    @Published private(set) var isSDKEnabled: Bool = false

    /// 是否开启 tracking（对应 RPEntry.instance.disableTracking 的反向状态）
    @Published private(set) var isTracking: Bool = false

    /// 行程列表（将来会从后端 / Damoov API 获取）
    @Published private(set) var trips: [Trip] = []
    
    /// 当前登录用户的 telematics 凭证（从 TelematicsAuthManager 拿到）
    @Published private(set) var credentials: TelematicsAuthManager.TelematicsCredentials?

    /// 当前使用的 virtualDeviceToken（方便调试）
    private var deviceToken: String? {
        credentials?.deviceToken
    }
    
    private init() {
        // 初始为空（不再使用 mock data）
        self.trips = []
    }
    
    // MARK: - Public API: 在登录 / 注册成功后调用
    
    /// 用 Damoov 返回的凭证配置 SDK
    func configure(with credentials: TelematicsAuthManager.TelematicsCredentials) {
        self.credentials = credentials
        initializeSDK(deviceToken: credentials.deviceToken)
    }
    
    // MARK: - SDK Initialization
    
    /// 实际执行 SDK 初始化 & 绑定 deviceToken 的地方
    /// - Important: RPEntry.initializeSDK() 必须已经在 AppDelegate 里调用过
    private func initializeSDK(deviceToken: String) {
        
        // 1. 绑定 deviceToken
        RPEntry.instance.virtualDeviceToken = deviceToken
        
        // 2. 启用 SDK
        RPEntry.instance.setEnableSdk(true)
        
        // 3. 自动 tracking（如果你用 disableTracking 控制开关）
        RPEntry.instance.disableTracking = false
        
        self.isSDKEnabled = true
        self.isTracking = true
        
        print("✅ Telematics SDK initialized with token: \(deviceToken.prefix(10))...")
    }
    
    /// 完全禁用 SDK（用于用户退出登录）
    func disableSDK() {
        RPEntry.instance.disableTracking = true
        RPEntry.instance.setEnableSdk(false)
        RPEntry.instance.removeVirtualDeviceToken()
        
        self.isSDKEnabled = false
        self.isTracking = false
        self.credentials = nil
        
        print("❌ Telematics SDK disabled")
    }
    
    // MARK: - Trip Management （未来接 DataHub API）

    /// 🚧 从后端 / Damoov 拉取 trips —— 占位逻辑，不再使用 mock 数据
    func fetchTrips() async throws -> [Trip] {
        
        // 未来你会改成：调用你的后端
        // https://your-backend.com/api/trips?deviceToken=XYZ
        
        // 当前返回已有的 trips（可能为空）
        return trips
    }
    
    func getAllTrips() -> [Trip] {
        trips
    }
    
    func getRecentTrips(days: Int = 30) -> [Trip] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return trips.filter { $0.startDate >= cutoff }
    }
    
    // MARK: - Tracking Control
    
    func startTracking() {
        guard isSDKEnabled else {
            print("⚠️ Cannot start tracking: SDK is not enabled")
            return
        }
        
        RPEntry.instance.disableTracking = false
        self.isTracking = true
        
        print("🚗 Started tracking")
    }
    
    func stopTracking() {
        guard isSDKEnabled else { return }
        
        RPEntry.instance.disableTracking = true
        self.isTracking = false
        
        print("🛑 Stopped tracking")
    }
    
    // TelematicsService.swift 里

    func requestPermissions() {
        PermissionManager.shared.requestLocationPermission()
        
        // 如果你想立刻再要 Motion，可以稍微延迟一下，体验好一点：
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            PermissionManager.shared.requestMotionPermission()
        }
    }

    func checkPermissions() -> Bool {
        PermissionManager.shared.hasAllPermissions()
    }

}

// MARK: - SDK Lifecycle Methods

extension TelematicsService {
    
    func applicationWillEnterForeground() {
        guard isSDKEnabled else { return }
        print("🌅 App entered foreground")
    }
    
    func applicationDidEnterBackground() {
        guard isSDKEnabled else { return }
        print("🌙 App entered background")
    }
}
