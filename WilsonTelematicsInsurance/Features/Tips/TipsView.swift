//
//  TipsView.swift
//  WilsonTelematicsInsurance
//
//  Features layer: Driving safety tips
//

import SwiftUI

struct TipsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Safe Driving Tips")) {
                    ForEach(DrivingTip.allTips) { tip in
                        TipRow(tip: tip)
                    }
                }
                
                Section(header: Text("Lower Your Premium")) {
                    ForEach(PremiumTip.allTips) { tip in
                        TipRow(tip: tip)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Tips & Advice")
        }
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let tip: Tip
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: tip.icon)
                .font(.title2)
                .foregroundColor(tip.color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.headline)
                
                Text(tip.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Tip Protocol and Types
protocol Tip: Identifiable {
    var id: String { get }
    var icon: String { get }
    var color: Color { get }
    var title: String { get }
    var description: String { get }
}

struct DrivingTip: Tip {
    let id: String
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    static let allTips: [DrivingTip] = [
        DrivingTip(
            id: "smooth-acceleration",
            icon: "hare.fill",
            color: .green,
            title: "Smooth Acceleration",
            description: "Gradually increase your speed when starting from a stop. Harsh acceleration wastes fuel and increases accident risk."
        ),
        DrivingTip(
            id: "gentle-braking",
            icon: "exclamationmark.brake.fill",
            color: .orange,
            title: "Gentle Braking",
            description: "Anticipate stops and brake gradually. Look ahead to avoid sudden stops, which reduces wear on your vehicle and improves safety."
        ),
        DrivingTip(
            id: "safe-following",
            icon: "car.2.fill",
            color: .blue,
            title: "Maintain Safe Following Distance",
            description: "Keep at least 3 seconds between you and the car ahead. This gives you time to react to sudden stops."
        ),
        DrivingTip(
            id: "no-phone",
            icon: "hand.raised.fill",
            color: .red,
            title: "No Phone While Driving",
            description: "Put your phone away or use a hands-free system. Distracted driving is a leading cause of accidents."
        ),
        DrivingTip(
            id: "speed-limits",
            icon: "speedometer",
            color: .yellow,
            title: "Respect Speed Limits",
            description: "Follow posted speed limits and adjust for weather and traffic conditions. Speeding increases accident severity."
        ),
        DrivingTip(
            id: "smooth-turns",
            icon: "arrow.turn.up.right",
            color: .purple,
            title: "Smooth Cornering",
            description: "Slow down before turns and accelerate gently through them. Sharp turns at high speeds increase rollover risk."
        ),
        DrivingTip(
            id: "defensive",
            icon: "eye.fill",
            color: .indigo,
            title: "Drive Defensively",
            description: "Always be aware of other drivers and anticipate their actions. Stay alert and ready to react."
        ),
        DrivingTip(
            id: "rest",
            icon: "powersleep",
            color: .cyan,
            title: "Take Breaks on Long Trips",
            description: "Stop every 2 hours or 100 miles on long drives. Fatigue significantly impairs driving ability."
        )
    ]
}

struct PremiumTip: Tip {
    let id: String
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    static let allTips: [PremiumTip] = [
        PremiumTip(
            id: "avoid-night",
            icon: "moon.stars.fill",
            color: .purple,
            title: "Limit Night Driving",
            description: "Accident rates are higher at night. When possible, schedule trips during daylight hours to reduce your risk score."
        ),
        PremiumTip(
            id: "avoid-rush",
            icon: "clock.badge.exclamationmark.fill",
            color: .orange,
            title: "Avoid Rush Hours",
            description: "Rush hour driving increases stress and accident risk. Plan trips outside peak traffic times when possible."
        ),
        PremiumTip(
            id: "consistent",
            icon: "chart.line.uptrend.xyaxis",
            color: .green,
            title: "Consistent Safe Driving",
            description: "Your premium is based on your driving patterns. Consistently safe driving over time will lower your rates."
        ),
        PremiumTip(
            id: "review",
            icon: "doc.text.magnifyingglass",
            color: .blue,
            title: "Review Your Trips",
            description: "Check your trip history regularly to identify patterns and areas for improvement. Knowledge is power!"
        ),
        PremiumTip(
            id: "reduce-mileage",
            icon: "figure.walk",
            color: .teal,
            title: "Reduce Total Mileage",
            description: "Consider alternative transportation for short trips. Less driving means less exposure to risk."
        ),
        PremiumTip(
            id: "plan-routes",
            icon: "map.fill",
            color: .pink,
            title: "Plan Your Routes",
            description: "Use familiar, well-maintained roads when possible. Better planning leads to safer, more predictable trips."
        )
    ]
}

#Preview {
    TipsView()
}
