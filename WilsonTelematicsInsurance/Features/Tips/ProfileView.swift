import SwiftUI

struct ProfileView: View {
    @StateObject private var auth = AuthViewModel()
    @StateObject private var telematics = TelematicsService.shared

    private var totalDistanceKm: Double {
        telematics.dailyStats.reduce(0) { $0 + $1.mileageKm }
    }

    private var totalTrips: Int {
        telematics.dailyStats.reduce(0) { $0 + $1.tripsCount }
    }

    private var totalHours: Double {
        telematics.dailyStats.reduce(0) { $0 + ($1.drivingTimeMin / 60.0) }
    }

    private var installDays: Int {
        guard let first = telematics.dailyStats.last?.date,
              let firstDate = ISO8601DateFormatter().date(from: first) else {
            return 0
        }
        let comps = Calendar.current.dateComponents([.day], from: firstDate, to: Date())
        return comps.day ?? 0
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    Text(auth.user?.email ?? "Unknown email")
                    Text("Device Token:")
                    Text(auth.telematicsDeviceToken ?? "N/A")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Section(header: Text("Driving Summary")) {
                    HStack {
                        Text("Install days")
                        Spacer()
                        Text("\(installDays)")
                    }
                    HStack {
                        Text("Total trips")
                        Spacer()
                        Text("\(totalTrips)")
                    }
                    HStack {
                        Text("Total distance")
                        Spacer()
                        Text(String(format: "%.1f km", totalDistanceKm))
                    }
                    HStack {
                        Text("Total driving time")
                        Spacer()
                        Text(String(format: "%.1f hrs", totalHours))
                    }
                }

                Section(header: Text("Next Period Premium (Demo)")) {
                    let premium = estimatePremium()
                    HStack {
                        Text("Estimated premium")
                        Spacer()
                        Text(String(format: "$%.2f / month", premium))
                            .bold()
                    }
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        Task { @MainActor in
                            auth.signOut()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }

    /// 一个非常简单的 demo 定价公式，后面你可以用自己的模型替换
    private func estimatePremium() -> Double {
        let base: Double = 100

        // 距离系数：越多越贵
        let distanceFactor = min(2.0, 1.0 + totalDistanceKm / 1000.0)

        // 行程数 + 小时数可以稍微调一下
        let tripsFactor = min(1.5, 1.0 + Double(totalTrips) / 500.0)
        let hoursFactor = min(1.5, 1.0 + totalHours / 500.0)

        return base * distanceFactor * tripsFactor * hoursFactor
    }
}
