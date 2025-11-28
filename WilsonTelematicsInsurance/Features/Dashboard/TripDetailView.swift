import SwiftUI

struct TripDetailView: View {
    // 直接用单例，不用 EnvironmentObject
    @ObservedObject private var telematicsService = TelematicsService.shared
    let trip: Trip

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: 地图折线
                if !telematicsService.currentTripCoordinates.isEmpty {
                    TripMapView(
                        coordinates: telematicsService.currentTripCoordinates,
                        events: telematicsService.currentTripEvents
                    )
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                } else {
                    Text("Loading route...")
                        .frame(height: 260)
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                }

                // MARK: 行程概要
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
                .padding(.horizontal)

                // MARK: 驾驶事件 & 手机使用
                VStack(alignment: .leading, spacing: 8) {
                    Text("Driving events")
                        .font(.headline)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Harsh braking")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(trip.harshBrakingCount)")
                                .font(.title3)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Harsh acceleration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(trip.harshAccelerationCount)")
                                .font(.title3)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Harsh cornering")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(trip.harshCorneringCount)")
                                .font(.title3)
                        }
                    }

                    Divider().padding(.vertical, 4)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Phone usage")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.0f s", trip.phoneUsageSeconds))
                                .font(.title3)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Night driving ratio")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.0f %%", trip.nightDrivingRatio * 100))
                                .font(.title3)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rush hour ratio")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.0f %%", trip.rushHourDrivingRatio * 100))
                                .font(.title3)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationTitle("Trip Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // 进入详情页时拉这个 trip 的 waypoints + events
            try? await telematicsService.fetchWaypoints(for: trip.id)
        }
        .onDisappear {
            telematicsService.clearCurrentTripRoute()
        }
    }
}
