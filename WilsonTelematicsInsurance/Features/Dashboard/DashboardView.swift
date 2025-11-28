//
//  DashboardView.swift
//  WilsonTelematicsInsurance
//
//  Features layer: Main dashboard showing driving overview
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var telematicsService = TelematicsService.shared
    @State private var driverFeatures: DriverFeatures?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Driving Score Card
                    if let features = driverFeatures {
                        DrivingScoreCard(score: features.calculateDrivingScore())
                    }
                    
                    // Trip Statistics
                    if let features = driverFeatures {
                        TripStatisticsSection(features: features)
                    }
                    
                    // MARK: - Recent trips + See all
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Trips")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            // 只有有行程的时候才显示 "See all"
                            if !telematicsService.trips.isEmpty {
                                NavigationLink {
                                    AllTripsView(trips: telematicsService.trips)
                                } label: {
                                    Text("See all")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // 只显示最近 3 条
                        RecentTripsSection(trips: Array(telematicsService.trips.prefix(3)))
                    }
                    
                    // Refresh Button
                    Button(action: refreshData) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh Data")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(isLoading)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .onAppear {
                calculateFeatures()
            }
        }
    }
    
    private func calculateFeatures() {
        let stats = telematicsService.dailyStats
        guard !stats.isEmpty else {
            self.driverFeatures = nil
            return
        }
        
        self.driverFeatures = DriverFeatures.fromDailyStats(stats)
    }

    
    private func refreshData() {
        guard telematicsService.credentials != nil else {
            print("❌ No telematics credentials, please login / create telematics user first")
            return
        }
        isLoading = true
        Task {
            do {
                _ = try await telematicsService.fetchTrips()      // 拉 trips
                _ = try await telematicsService.fetchDailyStats() // 拉 daily stats
                
                await MainActor.run {
                    calculateFeatures()
                    isLoading = false
                }
            } catch {
                print("Error refreshing data: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

}

// MARK: - Driving Score Card
struct DrivingScoreCard: View {
    let score: Double
    
    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .yellow
        case 40..<60: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Your Driving Score")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(String(format: "%.1f", score))
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(scoreColor)
            
            Text("out of 100")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(scoreDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private var scoreDescription: String {
        switch score {
        case 80...100: return "Excellent! You're a safe driver."
        case 60..<80: return "Good driving, but there's room for improvement."
        case 40..<60: return "Average. Consider safer driving habits."
        default: return "Needs improvement. Focus on safer driving."
        }
    }
}

// MARK: - Trip Statistics Section
struct TripStatisticsSection: View {
    let features: DriverFeatures
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    icon: "car.fill",
                    title: "Total Trips",
                    value: "\(features.totalTrips)"
                )
                
                StatCard(
                    icon: "gauge",
                    title: "Total Distance",
                    value: String(format: "%.1f km", features.totalDistance)
                )
                
                StatCard(
                    icon: "clock.fill",
                    title: "Total Hours",
                    value: String(format: "%.1f hrs", features.totalHours)
                )
                
                StatCard(
                    icon: "speedometer",
                    title: "Avg Speed",
                    value: String(format: "%.0f km/h", features.averageSpeed)
                )
            }
            .padding(.horizontal)
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

// MARK: - Recent Trips Section
struct RecentTripsSection: View {
    let trips: [Trip]
    
    var body: some View {
        if trips.isEmpty {
            Text("No trips recorded yet")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
        } else {
            VStack(spacing: 12) {
                ForEach(trips) { trip in
                    NavigationLink {
                        TripDetailView(trip: trip)
                    } label: {
                        TripRow(trip: trip)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Trip Row
struct TripRow: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading) {
                    Text(trip.startDate, style: .date)
                        .font(.headline)
                    Text(trip.startDate, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(format: "%.1f km", trip.distance))
                        .font(.headline)
                    Text(String(format: "%.0f min", trip.durationInMinutes))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 12) {
                Label(String(format: "%.0f km/h", trip.averageSpeed), systemImage: "speedometer")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if trip.harshBrakingCount > 0 {
                    Label("\(trip.harshBrakingCount) harsh", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                if trip.hasPhoneDistraction {
                    Label("Phone", systemImage: "phone.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

// MARK: - All Trips View（放在同一个文件）
// 不单独建文件，只是一个额外的 View，用于 "See all"
struct AllTripsView: View {
    let trips: [Trip]
    
    var body: some View {
        List(trips) { trip in
            NavigationLink {
                TripDetailView(trip: trip)
            } label: {
                TripRow(trip: trip)
            }
        }
        .navigationTitle("All Trips")
    }
}

#Preview {
    DashboardView()
}
