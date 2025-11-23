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
    
    @Published var isSDKEnabled: Bool = false
    @Published var isTracking: Bool = false
    @Published var trips: [Trip] = []
    
    private var deviceToken: String?
    
    private init() {
        // Initialize with mock data for now
        self.trips = Trip.mockTrips()
    }
    
    // MARK: - SDK Initialization
    
    /// Initialize the SDK with a device token
    /// - Parameter deviceToken: The virtual device token from the Damoov DataHub
    /// - Important: RPEntry.initializeSDK() must be called first in AppDelegate
    func initializeSDK(deviceToken: String) {
        self.deviceToken = deviceToken
        
        // Set the virtual device token
        // Note: RPEntry.initializeSDK() must have been called first in AppDelegate
        RPEntry.instance.virtualDeviceToken = deviceToken
        
        // Enable the SDK
        RPEntry.instance.setEnableSdk(true)
        
        self.isSDKEnabled = true
        
        print("✅ Telematics SDK initialized with token: \(deviceToken.prefix(10))...")
    }
    
    /// Disable the SDK
    func disableSDK() {
        RPEntry.instance.setEnableSdk(false)
        RPEntry.instance.removeVirtualDeviceToken()
        
        self.isSDKEnabled = false
        self.deviceToken = nil
        
        print("❌ Telematics SDK disabled")
    }
    
    // MARK: - Trip Management
    
    /// Fetch trips from the SDK
    /// Note: This is a placeholder. In a real app, you would implement
    /// the SDK's trip fetching methods and convert SDK trip objects to our Trip model
    func fetchTrips() async throws -> [Trip] {
        // TODO: Implement actual SDK trip fetching
        // For now, return mock data
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        
        let mockTrips = Trip.mockTrips()
        await MainActor.run {
            self.trips = mockTrips
        }
        
        return mockTrips
    }
    
    /// Get all trips
    func getAllTrips() -> [Trip] {
        return trips
    }
    
    /// Get recent trips (last N days)
    func getRecentTrips(days: Int = 30) -> [Trip] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return trips.filter { $0.startDate >= cutoffDate }
    }
    
    // MARK: - Tracking Control
    
    /// Start automatic trip tracking
    func startTracking() {
        // TODO: Implement SDK tracking start
        // RPEntry.instance.startTracking()
        
        self.isTracking = true
        print("🚗 Started tracking")
    }
    
    /// Stop automatic trip tracking
    func stopTracking() {
        // TODO: Implement SDK tracking stop
        // RPEntry.instance.stopTracking()
        
        self.isTracking = false
        print("🛑 Stopped tracking")
    }
    
    // MARK: - Permissions
    
    /// Check if all required permissions are granted
    func checkPermissions() -> Bool {
        // TODO: Implement actual permission checking
        // return RPEntry.instance.isAllRequiredPermissionsGranted()
        return true
    }
    
    /// Request necessary permissions
    func requestPermissions() {
        // TODO: Implement permission request flow
        // This typically involves requesting location and motion permissions
        print("📍 Requesting permissions...")
    }
}

// MARK: - SDK Lifecycle Methods
extension TelematicsService {
    /// Call this when the app enters foreground
    func applicationWillEnterForeground() {
        guard isSDKEnabled else { return }
        // RPEntry.instance.applicationWillEnterForeground(UIApplication.shared)
        print("🌅 App entered foreground")
    }
    
    /// Call this when the app enters background
    func applicationDidEnterBackground() {
        guard isSDKEnabled else { return }
        // RPEntry.instance.applicationDidEnterBackground(UIApplication.shared)
        print("🌙 App entered background")
    }
}
