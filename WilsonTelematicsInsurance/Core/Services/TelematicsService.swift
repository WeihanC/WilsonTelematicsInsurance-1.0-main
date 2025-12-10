//
//  TelematicsService.swift
//  WilsonTelematicsInsurance
//
//  Core layer: Service to interact with Telematics SDK & your Node backend
//

import Foundation
import TelematicsSDK
import Combine
import CoreLocation

@MainActor
class TelematicsService: ObservableObject {

    static let shared = TelematicsService()
    
    /// 一定要用 DrivingAlertManager.shared，和 AlertView 里的保持同一个实例
    let alertManager = DrivingAlertManager.shared

    // MARK: - Backend config
    /// 后端地址：真机上用你 Mac 的局域网 IP；模拟器上可以改回 http://localhost:4000
    private let backendBaseURL = URL(string: "https://wilson-telematics-backend-production.up.railway.app")!

    // MARK: - Published state
    @Published private(set) var isSDKEnabled: Bool = false
    @Published private(set) var isTracking: Bool = false
    @Published private(set) var trips: [Trip] = []
    @Published private(set) var credentials: TelematicsAuthManager.TelematicsCredentials?

    /// Daily stats（Dashboard 顶部大卡片用）
    @Published private(set) var dailyStats: [DailyStat] = []

    /// 当前展示的行程的路线 & 速度 & 事件（TripDetailView / TripMapView 用）
    @Published private(set) var currentTripCoordinates: [CLLocationCoordinate2D] = []
    @Published private(set) var currentTripSpeedSeries: [SpeedPoint] = []
    @Published private(set) var currentTripEvents: [MapEventPoint] = []

    /// 当前使用的 virtualDeviceToken（方便调试）
    private var deviceToken: String? {
        credentials?.deviceToken
    }

    private init() {
        self.trips = []
    }

    // MARK: - Setup after Login / Register
    /// 登录 / 注册成功后，用 Damoov 返回的凭证配置 SDK
    func configure(with credentials: TelematicsAuthManager.TelematicsCredentials) {
        self.credentials = credentials
        print("👤 Configuring telematics user, deviceToken = \(credentials.deviceToken)")
        initializeSDK(deviceToken: credentials.deviceToken)
    }
    
    

    // MARK: - Initialize SDK
    /// 实际执行 SDK 初始化 & 绑定 deviceToken 的地方
    /// - Important: RPEntry.initializeSDK() 必须已经在 AppDelegate 里调用过
    private func initializeSDK(deviceToken: String) {
        // 1. 绑定 deviceToken
        RPEntry.instance.virtualDeviceToken = deviceToken

        // 2. 启用 SDK
        RPEntry.instance.setEnableSdk(true)

        // 3. 自动 tracking
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

    // MARK: - Daily Stats Fetching

    func fetchDailyStats() async throws -> [DailyStat] {
        guard let credentials = credentials else {
            print("❌ No credentials for daily stats")
            return []
        }

        let jwt = credentials.jwt
        let url = backendBaseURL.appendingPathComponent("/api/daily-stats")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("❌ Daily stats backend error: \(http.statusCode), body: \(body)")
            return []
        }

        let decoded = try JSONDecoder().decode(DailyStatsResponse.self, from: data)
        dailyStats = decoded.days

        print("📊 Loaded daily stats: \(dailyStats.count) days")
        if let first = decoded.days.first {
            print("👉 First day mileage = \(first.mileageKm) km")
            print("👉 First day avgSpeed = \(first.avgSpeedKmh) km/h")
        }

        return dailyStats
    }

    // MARK: - Fetch Trips (from your Node backend)

    /// 从你自己的 Node.js 后端 /api/trips 拉取 trips，并更新到 @Published trips
    func fetchTrips() async throws -> [Trip] {
        // 1. 要有登录后的 telematics 凭证
        guard let credentials = credentials else {
            print("❌ No telematics credentials, cannot fetch trips")
            return []
        }

        // 使用你定义的 jwt 字段
        let jwt = credentials.jwt

        // 2. 构造请求到 Node.js 后端
        let url = backendBaseURL.appendingPathComponent("/api/trips")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        print("🌐 Calling backend: \(url.absoluteString) with jwt prefix: \(jwt.prefix(10)) ...")
        print("🔑 FULL JWT = \(jwt)")

        // 3. 发请求
        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("❌ Backend error: \(http.statusCode), body: \(body)")
            return []
        }

        // 4. 解码后端 JSON
        let backend = try JSONDecoder().decode(BackendTripsResponse.self, from: data)
        let backendTrips = backend.trips ?? []

        print("📥 Raw backend trips count: \(backendTrips.count)")

        // 5. 映射成你自己的 Trip 模型
        let mappedTrips = backendTrips.map { Trip(from: $0) }

        // 6. 更新到 @Published
        self.trips = mappedTrips

        // 7. 打印一些汇总信息，方便检查数据是否为 0
        let totalDistance = mappedTrips.reduce(0) { $0 + $1.distance }         // km
        let totalDuration = mappedTrips.reduce(0) { $0 + $1.duration }         // sec
        let avgSpeed = mappedTrips.isEmpty
            ? 0
            : mappedTrips.reduce(0) { $0 + $1.averageSpeed } / Double(mappedTrips.count)

        print("""
        ✅ Loaded \(mappedTrips.count) trips from backend
           • Total distance: \(String(format: "%.1f", totalDistance)) km
           • Total duration: \(String(format: "%.1f", totalDuration / 60)) min
           • Avg of per-trip avg speed: \(String(format: "%.1f", avgSpeed)) km/h
        """)

        if let first = mappedTrips.first {
            print("""
            🔎 First trip detail:
               id: \(first.id)
               start: \(first.startDate)
               end: \(first.endDate)
               distance: \(first.distance) km
               duration: \(first.duration) sec (\(String(format: "%.1f", first.durationInMinutes)) min)
               avgSpeed: \(first.averageSpeed) km/h
               maxSpeed: \(first.maxSpeed) km/h
               harshBraking: \(first.harshBrakingCount)
               harshAcceleration: \(first.harshAccelerationCount)
               harshCornering: \(first.harshCorneringCount)
               speedingEvents: \(first.speedingEvents)
               phoneUsageSeconds: \(first.phoneUsageSeconds)
               nightDrivingRatio: \(first.nightDrivingRatio)
               rushHourDrivingRatio: \(first.rushHourDrivingRatio)
            """)
        } else {
            print("ℹ️ No trips mapped from backend response.")
        }

        return mappedTrips
    }

    /// 直接返回当前内存里的 trips
    func getAllTrips() -> [Trip] {
        trips
    }

    func getRecentTrips(days: Int = 30) -> [Trip] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return trips.filter { $0.startDate >= cutoff }
    }

    // MARK: - Waypoints & Events for single trip

    func fetchWaypoints(for tripId: String) async throws {
        guard let credentials = credentials else {
            print("❌ No telematics credentials, cannot fetch waypoints")
            return
        }

        let jwt = credentials.jwt
        let url = backendBaseURL.appendingPathComponent("/api/trips/\(tripId)/waypoints")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        print("🌐 Calling backend (waypoints): \(url.absoluteString) with tripId = \(tripId)")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("❌ Backend waypoints error: \(http.statusCode), body: \(body)")
            return
        }

        do {
            let decoded = try JSONDecoder().decode(TripWaypointsResponse.self, from: data)

            currentTripCoordinates = decoded.polyline.map { $0.coordinate }
            currentTripSpeedSeries = decoded.speedSeries

            let events = decoded.events ?? []
            currentTripEvents = events.map { $0.asMapEventPoint }

            let brakingCount = currentTripEvents.filter { $0.kind == "braking" }.count
            let accelCount   = currentTripEvents.filter { $0.kind == "acceleration" }.count
            let cornerCount  = currentTripEvents.filter { $0.kind == "cornering" }.count
            let phoneCount   = currentTripEvents.filter { $0.kind == "phone" }.count

            print("""
            📍 Decoded waypoints: \(currentTripCoordinates.count) points
               speed samples: \(currentTripSpeedSeries.count)
               events: braking=\(brakingCount), accel=\(accelCount), corner=\(cornerCount), phone=\(phoneCount)
            """)

        } catch {
            print("❌ Failed to fetch/parse waypoints: \(error)")
            throw error
        }
    }

    func clearCurrentTripRoute() {
        currentTripCoordinates = []
        currentTripSpeedSeries = []
        currentTripEvents = []
    }

    // MARK: - Tracking Control

    func startTracking() {
        guard isSDKEnabled else {
            print("⚠️ Need SDK enabled")
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

    // MARK: - Permissions

    func requestPermissions() {
        PermissionManager.shared.requestLocationPermission()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            PermissionManager.shared.requestMotionPermission()
        }
    }

    func checkPermissions() -> Bool {
        PermissionManager.shared.hasAllPermissions()
    }
    
    // MARK: - 实时采样入口（给 AppDelegate / SDK 调）

    /// 举例：某个 SDK 回调 / Timer 每秒调用一次
    func handleRealtimeSample(speedMps: Double,
                              speedLimitMps: Double?,
                              accelMps2: Double?,
                              isHarshBrake: Bool,
                              isHarshAccel: Bool) {
        let sample = LiveDrivingSample(
            timestamp: Date(),
            speedMps: speedMps,
            speedLimitMps: speedLimitMps,
            accelMps2: accelMps2,
            isHarshBrakingEvent: isHarshBrake,
            isHarshAccelEvent: isHarshAccel
        )

        alertManager.process(sample: sample)
    }

    /// AppDelegate.onLocationChanged(_:) 可以直接用这个入口
    func handleLocationUpdateFromSDK(_ location: CLLocation) {
        let rawSpeed = location.speed
        let speedMps = rawSpeed > 0 ? rawSpeed : 0

        print("🚗 TelematicsService received location — speedMps =", speedMps)

        handleRealtimeSample(
            speedMps: speedMps,
            speedLimitMps: nil,      // 以后可以接真实限速
            accelMps2: nil,
            isHarshBrake: false,
            isHarshAccel: false
        )
    }

    /// 调试用：不用开车也能直接触发一次严重危险事件
    func debugTriggerSevereEvent() {
        DrivingAlertManager.shared.handleSDKEvent(type: "harsh_braking_debug")
    }
    
    
    // MARK: - Alert Event Logging / Reporting

    func logAlertEvent(_ alert: DrivingAlert) {
        // 本地先打印一条，万一之后你连上 Xcode，也能看到
        print("📡 [AlertEvent] level=\(alert.level) time=\(alert.time) msg=\(alert.message)")

        // 异步发给后端（忽略错误就行，防止影响用户体验）
        Task {
            await sendAlertEventToBackend(alert)
        }
    }

    private func sendAlertEventToBackend(_ alert: DrivingAlert) async {
        guard let credentials = credentials else {
            print("⚠️ No credentials, skip sending alert event")
            return
        }

        let jwt = credentials.jwt
        let url = backendBaseURL.appendingPathComponent("/api/alert-events")

        struct AlertEventPayload: Encodable {
            let time: String
            let level: String
            let message: String
        }

        let iso = ISO8601DateFormatter()
        let payload = AlertEventPayload(
            time: iso.string(from: alert.time),
            level: "\(alert.level)",  // 简单用字符串描述
            message: alert.message
        )

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(payload)

            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                print("❌ sendAlertEventToBackend httpStatus = \(http.statusCode)")
            } else {
                print("✅ Alert event sent to backend")
            }
        } catch {
            print("❌ Failed to send alert event: \(error)")
        }
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


// MARK: - Backend API Models (/api/trips)

/// 对应 Node.js 后端 /api/trips 的响应结构
struct BackendTripsResponse: Decodable {
    let source: String?
    let count: Int?
    let trips: [BackendTrip]?
}

/// 对应后端返回的单条行程（字段根据我们需要的指标设计）
struct BackendTrip: Decodable {
    let id: String?
    let startDate: String?
    let endDate: String?
    let distanceKm: Double?
    let durationSec: Double?
    let averageSpeedKmh: Double?
    let maxSpeedKmh: Double?
    let harshBrakingCount: Int?
    let harshAccelerationCount: Int?
    let harshCorneringCount: Int?
    let speedingEvents: Int?
    let phoneUsageSeconds: Double?
    let nightDrivingRatio: Double?
    let rushHourDrivingRatio: Double?
}


// MARK: - Trip mapping

extension Trip {
    init(from backend: BackendTrip) {
        let isoFormatter = ISO8601DateFormatter()

        let start = backend.startDate.flatMap { isoFormatter.date(from: $0) } ?? Date()
        let end = backend.endDate.flatMap { isoFormatter.date(from: $0) } ?? start

        self.init(
            id: backend.id ?? UUID().uuidString,
            startDate: start,
            endDate: end,
            distance: backend.distanceKm ?? 0,
            duration: backend.durationSec ?? 0,                   // 秒
            startLocation: nil,                                   // 暂时不用位置
            endLocation: nil,
            averageSpeed: backend.averageSpeedKmh ?? 0,
            maxSpeed: backend.maxSpeedKmh ?? (backend.averageSpeedKmh ?? 0),
            harshBrakingCount: backend.harshBrakingCount ?? 0,
            harshAccelerationCount: backend.harshAccelerationCount ?? 0,
            harshCorneringCount: backend.harshCorneringCount ?? 0,
            speedingEvents: backend.speedingEvents ?? 0,
            phoneUsageSeconds: backend.phoneUsageSeconds ?? 0,
            nightDrivingRatio: backend.nightDrivingRatio ?? 0,
            rushHourDrivingRatio: backend.rushHourDrivingRatio ?? 0
        )
    }
}
