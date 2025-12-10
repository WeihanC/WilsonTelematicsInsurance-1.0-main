//
//  PricingModel.swift
//  WilsonTelematicsInsurance
//
//  Core layer: Service to calculate insurance pricing from telematics data
//

import Foundation

/// Service class to calculate insurance pricing based on driving behavior
class PricingModel {
    static let shared = PricingModel()

    // Base pricing configuration (monthly in USD)
    private let basePremium: Double = 150.0
    private let minimumPremium: Double = 95.0
    private let maximumPremium: Double = 220.0
    
    private init() {}
    
    // MARK: - Pricing Calculation
    
    /// Calculate a pricing quote from driver features
    /// - Parameter features: Aggregated driving behavior features
    /// - Returns: A pricing quote with risk assessment and premium calculation
    func calculateQuote(from features: DriverFeatures) -> PricingQuote {
        // Calculate individual risk factors (0-1 scale)
        let speedingRisk = calculateSpeedingRisk(features)
        let harshBrakingRisk = calculateHarshBrakingRisk(features)
        let phoneUsageRisk = calculatePhoneUsageRisk(features)
        let nightDrivingRisk = calculateNightDrivingRisk(features)
        
        // Calculate overall risk score (0-100)
        let riskScore = calculateRiskScore(
            speedingRisk: speedingRisk,
            harshBrakingRisk: harshBrakingRisk,
            phoneUsageRisk: phoneUsageRisk,
            nightDrivingRisk: nightDrivingRisk
        )
        
        // Calculate driving score (inverse of risk score)
        let drivingScore = features.calculateDrivingScore()
        
        // Calculate adjusted premium based on risk score
        let adjustedPremium = calculatePremium(riskScore: riskScore)
        
        return PricingQuote(
            id: UUID().uuidString,
            generatedDate: Date(),
            drivingScore: drivingScore,
            riskScore: riskScore,
            baseMonthlyPremium: basePremium,
            adjustedMonthlyPremium: adjustedPremium,
            minimumMonthlyPremium: minimumPremium,
            maximumMonthlyPremium: maximumPremium,
            speedingRiskFactor: speedingRisk,
            harshBrakingRiskFactor: harshBrakingRisk,
            phoneUsageRiskFactor: phoneUsageRisk,
            nightDrivingRiskFactor: nightDrivingRisk
        )
    }
    
    /// Calculate a pricing quote from custom parameters (for the lab)
    /// - Parameters:
    ///   - harshBrakingRate: Harsh braking events per 100km
    ///   - speedingEventsPerTrip: Average speeding events per trip
    ///   - phoneUsageRatio: Phone usage ratio (0-1)
    ///   - nightDrivingRatio: Night driving ratio (0-1)
    /// - Returns: A pricing quote based on the custom parameters
    func calculateCustomQuote(
        harshBrakingRate: Double,
        speedingEventsPerTrip: Double,
        phoneUsageRatio: Double,
        nightDrivingRatio: Double
    ) -> PricingQuote {
        // Convert parameters to risk factors
        let speedingRisk = min(speedingEventsPerTrip / 10.0, 1.0)
        let harshBrakingRisk = min(harshBrakingRate / 5.0, 1.0)
        let phoneUsageRisk = phoneUsageRatio
        let nightDrivingRisk = nightDrivingRatio
        
        // Calculate risk score
        let riskScore = calculateRiskScore(
            speedingRisk: speedingRisk,
            harshBrakingRisk: harshBrakingRisk,
            phoneUsageRisk: phoneUsageRisk,
            nightDrivingRisk: nightDrivingRisk
        )
        
        // Calculate driving score (simplified)
        let drivingScore = max(100.0 - riskScore, 0.0)
        
        // Calculate premium
        let adjustedPremium = calculatePremium(riskScore: riskScore)
        
        return PricingQuote(
            id: UUID().uuidString,
            generatedDate: Date(),
            drivingScore: drivingScore,
            riskScore: riskScore,
            baseMonthlyPremium: basePremium,
            adjustedMonthlyPremium: adjustedPremium,
            minimumMonthlyPremium: minimumPremium,
            maximumMonthlyPremium: maximumPremium,
            speedingRiskFactor: speedingRisk,
            harshBrakingRiskFactor: harshBrakingRisk,
            phoneUsageRiskFactor: phoneUsageRisk,
            nightDrivingRiskFactor: nightDrivingRisk
        )
    }
    
    // MARK: - Risk Calculation
    
    private func calculateSpeedingRisk(_ features: DriverFeatures) -> Double {
        // More speeding events = higher risk
        return min(features.speedingEventsPerTrip / 10.0, 1.0)
    }
    
    private func calculateHarshBrakingRisk(_ features: DriverFeatures) -> Double {
        // More harsh braking = higher risk
        // Normalize by assuming 5 harsh braking events per 100km is very high risk
        return min(features.harshBrakingRate / 5.0, 1.0)
    }
    
    private func calculatePhoneUsageRisk(_ features: DriverFeatures) -> Double {
        // Phone usage ratio directly translates to risk
        return features.phoneUsageRatio
    }
    
    private func calculateNightDrivingRisk(_ features: DriverFeatures) -> Double {
        // Night driving increases risk
        return features.nightDrivingRatio
    }
    
    private func calculateRiskScore(
        speedingRisk: Double,
        harshBrakingRisk: Double,
        phoneUsageRisk: Double,
        nightDrivingRisk: Double
    ) -> Double {
        // Weighted combination of risk factors (0-100 scale)
        let weights: [Double] = [0.35, 0.30, 0.20, 0.15] // Speeding, harsh braking, phone, night
        let risks = [speedingRisk, harshBrakingRisk, phoneUsageRisk, nightDrivingRisk]
        
        let weightedRisk = zip(weights, risks).reduce(0.0) { $0 + $1.0 * $1.1 }
        return weightedRisk * 100.0
    }
    
    private func calculatePremium(riskScore: Double) -> Double {
        // Linear interpolation between min and max based on risk score
        // Low risk (0) → minimum premium
        // High risk (100) → maximum premium
        
        let premiumRange = maximumPremium - minimumPremium
        let adjustedPremium = minimumPremium + (premiumRange * (riskScore / 100.0))
        
        return min(max(adjustedPremium, minimumPremium), maximumPremium)
    }
}

// MARK: - Premium Ranges
extension PricingModel {
    /// Get the premium range for a given risk score
    func getPremiumRange(for riskScore: Double) -> (min: Double, max: Double) {
        let premium = calculatePremium(riskScore: riskScore)
        let variance = 15.0 // ±$15 range
        
        return (
            min: max(premium - variance, minimumPremium),
            max: min(premium + variance, maximumPremium)
        )
    }
    
    /// Get savings compared to base premium
    func getSavings(for premium: Double) -> Double {
        return basePremium - premium
    }
}
