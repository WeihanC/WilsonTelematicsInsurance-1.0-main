import Foundation
import CoreLocation

// MARK: - /api/trips 响应

struct TripsResponse: Codable {
    let source: String?
    let trips: [BackendTrip]
    let count: Int
}

struct BackendTrip: Identifiable, Codable {
    let id: String
    let startDate: String?
    let endDate: String?
    let distanceKm: Double
    let durationSec: Int
    let averageSpeedKmh: Double
    let maxSpeedKmh: Double
    let harshBrakingCount: Int
    let harshAccelerationCount: Int
    let harshCorneringCount: Int
    let speedingEvents: Int
    let phoneUsageSeconds: Int
    let nightDrivingRatio: Double
    let rushHourDrivingRatio: Double
}

// MARK: - /api/trips/:tripId/waypoints 响应

struct TripWaypointsResponse: Codable {
    let tripId: String
    let polyline: [BackendWaypoint]
    let speedSeries: [SpeedPoint]
}

struct BackendWaypoint: Codable {
    let lat: Double
    let lon: Double
}

struct SpeedPoint: Identifiable, Codable {
    let id = UUID()
    let t: Double
    let speedKmh: Double
}

// 方便把后端的 point 转成 CLLocationCoordinate2D
extension BackendWaypoint {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
