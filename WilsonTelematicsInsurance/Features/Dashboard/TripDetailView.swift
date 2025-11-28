import SwiftUI

struct TripDetailView: View {
    @EnvironmentObject var telematicsService: TelematicsService
    let trip: Trip

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: 地图折线
                if !telematicsService.currentTripCoordinates.isEmpty {
                    TripMapView(coordinates: telematicsService.currentTripCoordinates)
                        .frame(height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                } else {
                    // 还没拉到 waypoint 时的占位
                    Text("Loading route...")
                        .frame(height: 260)
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                }

                // MARK: 行程概要卡片
                TripSummaryCard(trip: trip)
                    .padding(.horizontal)

                // MARK: 简单速度列表（以后可以换成 Chart）
                if !telematicsService.currentTripSpeedSeries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Speed samples (every few sec)")
                            .font(.headline)

                        ForEach(telematicsService.currentTripSpeedSeries) { point in
                            HStack {
                                Text("\(Int(point.t)) s")
                                Spacer()
                                Text("\(Int(point.speedKmh)) km/h")
                            }
                            .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle("Trip Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // 进来就向后端要这个 trip 的 waypoints
            try? await telematicsService.fetchWaypoints(for: trip.id)
        }
        .onDisappear {
            // 离开页面时清空，避免下次进来残留旧路线
            telematicsService.clearCurrentTripRoute()
        }
    }
}

struct TripSummaryCard: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trip summary")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f km", trip.distance))
                        .font(.title3)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f min", trip.durationInMinutes))
                        .font(.title3)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg speed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(trip.averageSpeed)) km/h")
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Max speed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(trip.maxSpeed)) km/h")
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
