import Foundation
import CoreLocation

@MainActor
class TripDetailViewModel: ObservableObject {
    @Published var coords: [CLLocationCoordinate2D] = []
    @Published var speedSeries: [BackendSpeedPoint] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func loadWaypoints(tripId: String) async {
        guard let url = URL(string: "http://localhost:4000/api/trips/\(tripId)/waypoints") else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // 如果你在 app 里有 user JWT，这里记得加上：
            // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(BackendWaypointsResponse.self, from: data)
            
            self.coords = decoded.polyline.map { $0.coordinate }
            self.speedSeries = decoded.speedSeries
            self.isLoading = false
        } catch {
            print("❌ loadWaypoints error:", error)
            self.errorMessage = "Failed to load trip waypoints"
            self.isLoading = false
        }
    }
}
