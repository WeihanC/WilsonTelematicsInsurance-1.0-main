import SwiftUI

struct TripDetailView: View {
    let trip: Trip
    
    private var durationText: String {
        String(format: "%.0f min", trip.durationInMinutes)
    }
    
    private var distanceText: String {
        String(format: "%.1f km", trip.distance)
    }
    
    private var avgSpeedText: String {
        String(format: "%.0f km/h", trip.averageSpeed)
    }
    
    private var maxSpeedText: String {
        String(format: "%.0f km/h", trip.maxSpeed)
    }
    
    private var phoneUsageText: String {
        if trip.phoneUsageSeconds <= 0 {
            return "No phone usage detected"
        } else {
            let minutes = trip.phoneUsageSeconds / 60.0
            return String(format: "%.0f min of phone usage", minutes)
        }
    }
    
    private var nightRatioText: String {
        String(format: "%.0f%% of time at night", trip.nightDrivingRatio * 100)
    }
    
    private var rushHourRatioText: String {
        String(format: "%.0f%% of time in rush hour", trip.rushHourDrivingRatio * 100)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header：日期 + 时间
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.startDate, style: .date)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("\(trip.startDate.formatted(date: .omitted, time: .shortened))  –  \(trip.endDate.formatted(date: .omitted, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // 基本行程信息
                VStack(alignment: .leading, spacing: 12) {
                    Text("Trip Summary")
                        .font(.headline)
                    
                    HStack {
                        SummaryItem(title: "Distance", value: distanceText, systemImage: "map")
                        Spacer()
                        SummaryItem(title: "Duration", value: durationText, systemImage: "clock")
                    }
                    
                    HStack {
                        SummaryItem(title: "Avg Speed", value: avgSpeedText, systemImage: "speedometer")
                        Spacer()
                        SummaryItem(title: "Max Speed", value: maxSpeedText, systemImage: "gauge.with.dots.needle.67percent")
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                // 驾驶行为事件
                VStack(alignment: .leading, spacing: 12) {
                    Text("Driving Events")
                        .font(.headline)
                    
                    HStack {
                        EventItem(title: "Harsh Braking", value: trip.harshBrakingCount, systemImage: "exclamationmark.brakesignal")
                        Spacer()
                        EventItem(title: "Harsh Accel", value: trip.harshAccelerationCount, systemImage: "arrow.up.to.line.compact")
                    }
                    
                    HStack {
                        EventItem(title: "Harsh Corner", value: trip.harshCorneringCount, systemImage: "steeringwheel")
                        Spacer()
                        EventItem(title: "Speeding", value: trip.speedingEvents, systemImage: "speedometer")
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                // 时间分布 + 手机使用
                VStack(alignment: .leading, spacing: 12) {
                    Text("Time & Distraction")
                        .font(.headline)
                    
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label(nightRatioText, systemImage: "moon.stars")
                                .font(.subheadline)
                            Label(rushHourRatioText, systemImage: "car.2")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Label(phoneUsageText, systemImage: "phone.fill")
                                .font(.subheadline)
                                .foregroundColor(trip.hasPhoneDistraction ? .red : .secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Trip Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 小组件：SummaryItem
private struct SummaryItem: View {
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
    }
}

// 小组件：EventItem
private struct EventItem: View {
    let title: String
    let value: Int
    let systemImage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.headline)
        }
    }
}

#Preview {
    NavigationView {
        TripDetailView(trip: Trip.mockSingleTrip())
    }
}
