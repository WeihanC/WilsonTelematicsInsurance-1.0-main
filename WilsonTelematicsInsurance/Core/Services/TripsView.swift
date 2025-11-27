import SwiftUI

struct TripsView: View {
    @StateObject private var telematicsService = TelematicsService.shared
    
    private var sortedTrips: [Trip] {
        telematicsService.getAllTrips()
            .sorted { $0.startDate > $1.startDate }
    }
    
    var body: some View {
        List {
            if sortedTrips.isEmpty {
                Section {
                    VStack(alignment: .center, spacing: 8) {
                        Text("No trips recorded yet")
                            .font(.headline)
                        Text("Go for a short drive to see your first trip here.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            } else {
                ForEach(sortedTrips) { trip in
                    NavigationLink(destination: TripDetailView(trip: trip)) {
                        TripRow(trip: trip)   // 复用你现有的 TripRow
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("All Trips")
        .onAppear {
            Task {
                // 如果当前内存里还没有 trips，就主动拉取一次
                if telematicsService.getAllTrips().isEmpty {
                    do {
                        _ = try await telematicsService.fetchTrips()
                    } catch {
                        print("❌ Failed to fetch trips in TripsView: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        TripsView()
    }
}
