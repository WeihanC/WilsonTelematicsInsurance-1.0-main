//
//  Trip.swift
//  WilsonTelematicsInsurance
//
//  Core layer: Domain model for telematics trip data
//

import Foundation
import CoreLocation

/// Represents a driving trip with telematics data
struct Trip: Identifiable, Codable {
    let id: String
    let startDate: Date
    let endDate: Date
    let distance: Double // in kilometers
    let duration: TimeInterval // in seconds
    let startLocation: Coordinate?
    let endLocation: Coordinate?
    
    // Driving behavior metrics
    let averageSpeed: Double // km/h
    let maxSpeed: Double // km/h
    let harshBrakingCount: Int
    let harshAccelerationCount: Int
    let harshCorneringCount: Int
    let speedingEvents: Int
    let phoneUsageSeconds: TimeInterval
    
    // Time-based metrics
    let nightDrivingRatio: Double // 0.0 to 1.0
    let rushHourDrivingRatio: Double // 0.0 to 1.0
    
    // Computed properties
    var durationInMinutes: Double {
        duration / 60.0
    }
    
    var durationInHours: Double {
        duration / 3600.0
    }
    
    var isNightTrip: Bool {
        nightDrivingRatio > 0.5
    }
    
    var hasPhoneDistraction: Bool {
        phoneUsageSeconds > 0
    }
}

/// Coordinate wrapper for Codable conformance
struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Mock Data Extension
extension Trip {
    /// Generate mock trip data for testing
    static func mockTrips() -> [Trip] {
        let now = Date()
        return [
            Trip(
                id: UUID().uuidString,
                startDate: now.addingTimeInterval(-7200),
                endDate: now.addingTimeInterval(-5400),
                distance: 25.5,
                duration: 1800,
                startLocation: Coordinate(latitude: 37.7749, longitude: -122.4194),
                endLocation: Coordinate(latitude: 37.8044, longitude: -122.2712),
                averageSpeed: 45.0,
                maxSpeed: 80.0,
                harshBrakingCount: 2,
                harshAccelerationCount: 1,
                harshCorneringCount: 3,
                speedingEvents: 5,
                phoneUsageSeconds: 120,
                nightDrivingRatio: 0.0,
                rushHourDrivingRatio: 0.8
            ),
            Trip(
                id: UUID().uuidString,
                startDate: now.addingTimeInterval(-86400),
                endDate: now.addingTimeInterval(-85200),
                distance: 12.3,
                duration: 1200,
                startLocation: Coordinate(latitude: 37.8044, longitude: -122.2712),
                endLocation: Coordinate(latitude: 37.7749, longitude: -122.4194),
                averageSpeed: 38.0,
                maxSpeed: 65.0,
                harshBrakingCount: 0,
                harshAccelerationCount: 0,
                harshCorneringCount: 1,
                speedingEvents: 1,
                phoneUsageSeconds: 0,
                nightDrivingRatio: 0.9,
                rushHourDrivingRatio: 0.1
            ),
            Trip(
                id: UUID().uuidString,
                startDate: now.addingTimeInterval(-172800),
                endDate: now.addingTimeInterval(-170400),
                distance: 45.8,
                duration: 2400,
                startLocation: Coordinate(latitude: 37.7749, longitude: -122.4194),
                endLocation: Coordinate(latitude: 37.3382, longitude: -121.8863),
                averageSpeed: 68.0,
                maxSpeed: 95.0,
                harshBrakingCount: 4,
                harshAccelerationCount: 3,
                harshCorneringCount: 2,
                speedingEvents: 12,
                phoneUsageSeconds: 240,
                nightDrivingRatio: 0.2,
                rushHourDrivingRatio: 0.3
            )
        ]
    }
    
    static func mockSingleTrip() -> Trip {
        mockTrips()[0]
    }
}
