//
//  DriverFeatures.swift
//  WilsonTelematicsInsurance
//
//  Core layer: Aggregated driving behavior features for risk assessment
//

import Foundation

/// Aggregated driving behavior features extracted from multiple trips
struct DriverFeatures: Codable {
    // Trip volume
    let totalTrips: Int
    let totalDistance: Double // km
    let totalDuration: TimeInterval // seconds
    
    // Speed metrics
    let averageSpeed: Double // km/h
    let maxSpeedRecorded: Double // km/h
    let speedingEventsPerTrip: Double
    
    // Harsh event metrics (per 100 km)
    let harshBrakingRate: Double
    let harshAccelerationRate: Double
    let harshCorneringRate: Double
    
    // Phone distraction
    let phoneUsageRatio: Double // 0.0 to 1.0
    
    // Time-based risk factors
    let nightDrivingRatio: Double // 0.0 to 1.0
    let rushHourDrivingRatio: Double // 0.0 to 1.0
    
    // Computed properties
    var averageTripDistance: Double {
        totalTrips > 0 ? totalDistance / Double(totalTrips) : 0
    }
    
    var totalHours: Double {
        totalDuration / 3600.0
    }
    
    /// Calculate an overall driving score (0-100, higher is better)
    func calculateDrivingScore() -> Double {
        var score = 100.0
        
        // Deduct points for harsh events
        score -= min(harshBrakingRate * 2.0, 15.0)
        score -= min(harshAccelerationRate * 2.0, 15.0)
        score -= min(harshCorneringRate * 1.5, 10.0)
        
        // Deduct points for speeding
        score -= min(speedingEventsPerTrip * 3.0, 20.0)
        
        // Deduct points for phone usage
        score -= phoneUsageRatio * 15.0
        
        // Deduct points for risky time periods
        score -= nightDrivingRatio * 10.0
        score -= rushHourDrivingRatio * 5.0
        
        return max(score, 0.0)
    }
}

// MARK: - Initialization from Trips
extension DriverFeatures {
    /// Initialize from an array of trips
    init(from trips: [Trip]) {
        self.totalTrips = trips.count
        self.totalDistance = trips.reduce(0) { $0 + $1.distance }
        self.totalDuration = trips.reduce(0) { $0 + $1.duration }
        
        // Calculate averages
        if trips.isEmpty {
            self.averageSpeed = 0
            self.maxSpeedRecorded = 0
            self.speedingEventsPerTrip = 0
            self.harshBrakingRate = 0
            self.harshAccelerationRate = 0
            self.harshCorneringRate = 0
            self.phoneUsageRatio = 0
            self.nightDrivingRatio = 0
            self.rushHourDrivingRatio = 0
        } else {
            self.averageSpeed = trips.reduce(0) { $0 + $1.averageSpeed } / Double(trips.count)
            self.maxSpeedRecorded = trips.map { $0.maxSpeed }.max() ?? 0
            self.speedingEventsPerTrip = Double(trips.reduce(0) { $0 + $1.speedingEvents }) / Double(trips.count)
            
            // Calculate harsh event rates per 100 km
            let totalHarshBraking = trips.reduce(0) { $0 + $1.harshBrakingCount }
            let totalHarshAcceleration = trips.reduce(0) { $0 + $1.harshAccelerationCount }
            let totalHarshCornering = trips.reduce(0) { $0 + $1.harshCorneringCount }
            
            self.harshBrakingRate = totalDistance > 0 ? Double(totalHarshBraking) / totalDistance * 100 : 0
            self.harshAccelerationRate = totalDistance > 0 ? Double(totalHarshAcceleration) / totalDistance * 100 : 0
            self.harshCorneringRate = totalDistance > 0 ? Double(totalHarshCornering) / totalDistance * 100 : 0
            
            // Calculate phone usage ratio
            let totalPhoneUsage = trips.reduce(0) { $0 + $1.phoneUsageSeconds }
            self.phoneUsageRatio = totalDuration > 0 ? totalPhoneUsage / totalDuration : 0
            
            // Calculate time-based ratios
            self.nightDrivingRatio = trips.reduce(0) { $0 + $1.nightDrivingRatio } / Double(trips.count)
            self.rushHourDrivingRatio = trips.reduce(0) { $0 + $1.rushHourDrivingRatio } / Double(trips.count)
        }
    }
}

// MARK: - Mock Data
extension DriverFeatures {
    static func mock() -> DriverFeatures {
        DriverFeatures(from: Trip.mockTrips())
    }
    
    static func mockSafeDriver() -> DriverFeatures {
        DriverFeatures(
            totalTrips: 50,
            totalDistance: 800,
            totalDuration: 36000,
            averageSpeed: 45,
            maxSpeedRecorded: 75,
            speedingEventsPerTrip: 0.5,
            harshBrakingRate: 0.8,
            harshAccelerationRate: 0.6,
            harshCorneringRate: 1.0,
            phoneUsageRatio: 0.02,
            nightDrivingRatio: 0.15,
            rushHourDrivingRatio: 0.25
        )
    }
    
    static func mockRiskyDriver() -> DriverFeatures {
        DriverFeatures(
            totalTrips: 50,
            totalDistance: 1200,
            totalDuration: 42000,
            averageSpeed: 65,
            maxSpeedRecorded: 110,
            speedingEventsPerTrip: 8.5,
            harshBrakingRate: 5.2,
            harshAccelerationRate: 4.8,
            harshCorneringRate: 3.5,
            phoneUsageRatio: 0.18,
            nightDrivingRatio: 0.45,
            rushHourDrivingRatio: 0.55
        )
    }
}
