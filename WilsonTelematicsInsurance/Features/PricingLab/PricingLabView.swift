//
//  PricingLabView.swift
//  WilsonTelematicsInsurance
//
//  Features layer: Interactive pricing laboratory
//

import SwiftUI

struct PricingLabView: View {
    @State private var harshBrakingRate: Double = 2.0 // per 100km
    @State private var speedingEventsPerTrip: Double = 3.0
    @State private var phoneUsageRatio: Double = 0.1 // 0-1
    @State private var nightDrivingRatio: Double = 0.2 // 0-1
    
    @State private var currentQuote: PricingQuote?
    
    private let pricingModel = PricingModel.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Insurance Pricing Lab")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Adjust the sliders to see how your driving behavior affects your insurance premium")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // Quote Display
                    if let quote = currentQuote {
                        QuoteDisplayCard(quote: quote)
                    }
                    
                    // Parameters Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Driving Behavior Parameters")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ParameterSlider(
                            title: "Harsh Braking",
                            subtitle: "Events per 100 km",
                            value: $harshBrakingRate,
                            range: 0...10,
                            step: 0.5,
                            icon: "exclamationmark.brake.fill"
                        )
                        
                        ParameterSlider(
                            title: "Speeding Events",
                            subtitle: "Per trip",
                            value: $speedingEventsPerTrip,
                            range: 0...15,
                            step: 0.5,
                            icon: "speedometer"
                        )
                        
                        ParameterSlider(
                            title: "Phone Usage",
                            subtitle: "Percentage of driving time",
                            value: $phoneUsageRatio,
                            range: 0...0.5,
                            step: 0.01,
                            displayMultiplier: 100,
                            icon: "phone.fill"
                        )
                        
                        ParameterSlider(
                            title: "Night Driving",
                            subtitle: "Percentage of trips",
                            value: $nightDrivingRatio,
                            range: 0...1,
                            step: 0.05,
                            displayMultiplier: 100,
                            icon: "moon.fill"
                        )
                    }
                    
                    // Reset Button
                    Button(action: resetToAverage) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Average Driver")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Pricing Lab")
            .onAppear {
                calculateQuote()
            }
            .onChange(of: harshBrakingRate) { _ in calculateQuote() }
            .onChange(of: speedingEventsPerTrip) { _ in calculateQuote() }
            .onChange(of: phoneUsageRatio) { _ in calculateQuote() }
            .onChange(of: nightDrivingRatio) { _ in calculateQuote() }
        }
    }
    
    private func calculateQuote() {
        currentQuote = pricingModel.calculateCustomQuote(
            harshBrakingRate: harshBrakingRate,
            speedingEventsPerTrip: speedingEventsPerTrip,
            phoneUsageRatio: phoneUsageRatio,
            nightDrivingRatio: nightDrivingRatio
        )
    }
    
    private func resetToAverage() {
        harshBrakingRate = 2.0
        speedingEventsPerTrip = 3.0
        phoneUsageRatio = 0.1
        nightDrivingRatio = 0.2
    }
}

// MARK: - Quote Display Card
struct QuoteDisplayCard: View {
    let quote: PricingQuote
    
    var body: some View {
        VStack(spacing: 16) {
            // Risk Score
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Risk Score")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", quote.riskScore))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(riskScoreColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Driving Score")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", quote.drivingScore))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            
            Divider()
            
            // Premium Display
            VStack(spacing: 8) {
                Text("Estimated Monthly Premium")
                    .font(.headline)
                
                Text(String(format: "$%.2f", quote.adjustedMonthlyPremium))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
                
                HStack {
                    Text("Base: $\(Int(quote.baseMonthlyPremium))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if quote.monthlySavings > 0 {
                        Text("Savings: $\(String(format: "%.2f", quote.monthlySavings))")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Increase: $\(String(format: "%.2f", abs(quote.monthlySavings)))")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Text("Range: $\(Int(quote.minimumMonthlyPremium)) - $\(Int(quote.maximumMonthlyPremium))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Risk Breakdown
            VStack(alignment: .leading, spacing: 8) {
                Text("Risk Factor Breakdown")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                RiskFactorBar(title: "Speeding", value: quote.speedingRiskFactor)
                RiskFactorBar(title: "Harsh Braking", value: quote.harshBrakingRiskFactor)
                RiskFactorBar(title: "Phone Usage", value: quote.phoneUsageRiskFactor)
                RiskFactorBar(title: "Night Driving", value: quote.nightDrivingRiskFactor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private var riskScoreColor: Color {
        switch quote.riskScore {
        case 0..<25: return .green
        case 25..<50: return .yellow
        case 50..<75: return .orange
        default: return .red
        }
    }
}

// MARK: - Risk Factor Bar
struct RiskFactorBar: View {
    let title: String
    let value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.0f%%", value * 100))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(barColor)
                        .frame(width: geometry.size.width * value, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
    
    private var barColor: Color {
        switch value {
        case 0..<0.25: return .green
        case 0.25..<0.5: return .yellow
        case 0.5..<0.75: return .orange
        default: return .red
        }
    }
}

// MARK: - Parameter Slider
struct ParameterSlider: View {
    let title: String
    let subtitle: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    var displayMultiplier: Double = 1.0
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(String(format: "%.1f", value * displayMultiplier))
                    .font(.headline)
                    .monospacedDigit()
            }
            
            Slider(value: $value, in: range, step: step)
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}

#Preview {
    PricingLabView()
}
