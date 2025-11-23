//
//  PricingQuote.swift
//  WilsonTelematicsInsurance
//
//  Core layer: Insurance pricing quote model
//

import Foundation

/// Represents an insurance pricing quote based on driving behavior
struct PricingQuote: Identifiable, Codable {
    let id: String
    let generatedDate: Date
    let drivingScore: Double // 0-100
    let riskScore: Double // 0-100, higher = riskier
    
    // Pricing information (monthly in USD)
    let baseMonthlyPremium: Double
    let adjustedMonthlyPremium: Double
    let minimumMonthlyPremium: Double
    let maximumMonthlyPremium: Double
    
    // Risk factors breakdown
    let speedingRiskFactor: Double // 0-1
    let harshBrakingRiskFactor: Double // 0-1
    let phoneUsageRiskFactor: Double // 0-1
    let nightDrivingRiskFactor: Double // 0-1
    
    // Computed properties
    var monthlySavings: Double {
        baseMonthlyPremium - adjustedMonthlyPremium
    }
    
    var annualPremium: Double {
        adjustedMonthlyPremium * 12
    }
    
    var discountPercentage: Double {
        guard baseMonthlyPremium > 0 else { return 0 }
        return ((baseMonthlyPremium - adjustedMonthlyPremium) / baseMonthlyPremium) * 100
    }
    
    var riskLevel: RiskLevel {
        switch riskScore {
        case 0..<25:
            return .low
        case 25..<50:
            return .moderate
        case 50..<75:
            return .high
        default:
            return .veryHigh
        }
    }
}

// MARK: - Supporting Types
extension PricingQuote {
    enum RiskLevel: String, Codable {
        case low = "Low Risk"
        case moderate = "Moderate Risk"
        case high = "High Risk"
        case veryHigh = "Very High Risk"
        
        var color: String {
            switch self {
            case .low: return "green"
            case .moderate: return "yellow"
            case .high: return "orange"
            case .veryHigh: return "red"
            }
        }
    }
}

// MARK: - Mock Data
extension PricingQuote {
    static func mock() -> PricingQuote {
        PricingQuote(
            id: UUID().uuidString,
            generatedDate: Date(),
            drivingScore: 78.5,
            riskScore: 32.0,
            baseMonthlyPremium: 150.0,
            adjustedMonthlyPremium: 112.50,
            minimumMonthlyPremium: 95.0,
            maximumMonthlyPremium: 220.0,
            speedingRiskFactor: 0.25,
            harshBrakingRiskFactor: 0.15,
            phoneUsageRiskFactor: 0.10,
            nightDrivingRiskFactor: 0.20
        )
    }
    
    static func mockSafeDriver() -> PricingQuote {
        PricingQuote(
            id: UUID().uuidString,
            generatedDate: Date(),
            drivingScore: 92.3,
            riskScore: 15.5,
            baseMonthlyPremium: 150.0,
            adjustedMonthlyPremium: 98.50,
            minimumMonthlyPremium: 95.0,
            maximumMonthlyPremium: 220.0,
            speedingRiskFactor: 0.05,
            harshBrakingRiskFactor: 0.08,
            phoneUsageRiskFactor: 0.02,
            nightDrivingRiskFactor: 0.12
        )
    }
    
    static func mockRiskyDriver() -> PricingQuote {
        PricingQuote(
            id: UUID().uuidString,
            generatedDate: Date(),
            drivingScore: 45.8,
            riskScore: 72.3,
            baseMonthlyPremium: 150.0,
            adjustedMonthlyPremium: 198.75,
            minimumMonthlyPremium: 95.0,
            maximumMonthlyPremium: 220.0,
            speedingRiskFactor: 0.65,
            harshBrakingRiskFactor: 0.55,
            phoneUsageRiskFactor: 0.48,
            nightDrivingRiskFactor: 0.52
        )
    }
}
