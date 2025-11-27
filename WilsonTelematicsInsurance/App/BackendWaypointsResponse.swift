import Foundation
import CoreLocation

struct BackendWaypointsResponse: Codable {
    let tripId: String
    let polyline: [BackendCoordinate]
    let speedSeries: [BackendSpeedPoint]
}

struct BackendCoordinate: Codable {
    let lat: Double
    let lon: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct BackendSpeedPoint: Codable, Identifiable {
    let t: Double       // 秒
    let speedKmh: Double
    
    var id: Double { t }
}
