import SwiftUI
import MapKit

struct TripMapView: View {
    let coords: [CLLocationCoordinate2D]
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $cameraPosition) {
            if !coords.isEmpty {
                // 路线 polyline
                MapPolyline(coordinates: coords)
                    .stroke(.blue, lineWidth: 4)
                
                // 起点
                if let start = coords.first {
                    Annotation("Start", coordinate: start) {
                        Image(systemName: "flag.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
                
                // 终点
                if let end = coords.last {
                    Annotation("End", coordinate: end) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            if let first = coords.first {
                let region = MKCoordinateRegion(
                    center: first,
                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                )
                cameraPosition = .region(region)
            }
        }
    }
}
