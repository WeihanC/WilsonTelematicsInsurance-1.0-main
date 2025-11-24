//
//  DriverFeatures.swift
//  WilsonTelematicsInsurance
//
//  聚合驾驶数据，用于 Dashboard 统计 & 保险定价
//

import Foundation

struct DriverFeatures {
    // 核心聚合指标
    let totalTrips: Int
    let totalDistance: Double      // km
    let totalHours: Double         // h
    let averageSpeed: Double       // km/h
    
    // 行为风险指标（总量）
    let totalBrakings: Int
    let totalAccelerations: Int
    let totalCornerings: Int
    let totalPhoneUsageMin: Double
    let totalSpeedingKm: Double
    let totalNightDrivingMin: Double
    
    // MARK: - 主构造函数
    init(
        totalTrips: Int,
        totalDistance: Double,
        totalHours: Double,
        averageSpeed: Double,
        totalBrakings: Int = 0,
        totalAccelerations: Int = 0,
        totalCornerings: Int = 0,
        totalPhoneUsageMin: Double = 0,
        totalSpeedingKm: Double = 0,
        totalNightDrivingMin: Double = 0
    ) {
        self.totalTrips = totalTrips
        self.totalDistance = totalDistance
        self.totalHours = totalHours
        self.averageSpeed = averageSpeed
        self.totalBrakings = totalBrakings
        self.totalAccelerations = totalAccelerations
        self.totalCornerings = totalCornerings
        self.totalPhoneUsageMin = totalPhoneUsageMin
        self.totalSpeedingKm = totalSpeedingKm
        self.totalNightDrivingMin = totalNightDrivingMin
    }
    
    // MARK: - 从 DailyStats 聚合（Dashboard / Pricing 正在用）
    static func fromDailyStats(_ stats: [DailyStat]) -> DriverFeatures {
        let totalDistance = stats.reduce(0) { $0 + $1.mileageKm }
        let totalTrips = stats.reduce(0) { $0 + $1.tripsCount }
        let totalDrivingMin = stats.reduce(0) { $0 + $1.drivingTimeMin }
        let totalBrakings = stats.reduce(0) { $0 + $1.brakingsCount }
        let totalAccelerations = stats.reduce(0) { $0 + $1.accelerationsCount }
        let totalCornerings = stats.reduce(0) { $0 + $1.corneringsCount }
        let totalPhoneUsageMin = stats.reduce(0) { $0 + $1.phoneUsageMin }
        let totalSpeedingKm = stats.reduce(0) { $0 + $1.speedingKm }
        let totalNightDrivingMin = stats.reduce(0) { $0 + $1.nightDrivingMin }
        
        let avgSpeed = totalDrivingMin > 0
            ? (totalDistance / (totalDrivingMin / 60.0))
            : 0
        
        return DriverFeatures(
            totalTrips: totalTrips,
            totalDistance: totalDistance,
            totalHours: totalDrivingMin / 60.0,
            averageSpeed: avgSpeed,
            totalBrakings: totalBrakings,
            totalAccelerations: totalAccelerations,
            totalCornerings: totalCornerings,
            totalPhoneUsageMin: totalPhoneUsageMin,
            totalSpeedingKm: totalSpeedingKm,
            totalNightDrivingMin: totalNightDrivingMin
        )
    }
    
    // MARK: - 可选：从 Trip 列表聚合（老逻辑保留）
    static func fromTrips(_ trips: [Trip]) -> DriverFeatures {
        let totalDistance = trips.reduce(0) { $0 + $1.distance }
        let totalTrips = trips.count
        let totalMinutes = trips.reduce(0) { $0 + $1.durationInMinutes }
        let avgSpeed = totalMinutes > 0
            ? (totalDistance / (totalMinutes / 60.0))
            : 0
        
        let totalBrakings = trips.reduce(0) { $0 + $1.harshBrakingCount }
        let totalAccelerations = 0
        let totalCornerings = 0
        let totalPhoneUsageMin = trips.reduce(0) { $0 + $1.phoneUsageSeconds / 60.0 }
        let totalSpeedingKm: Double = 0
        let totalNightDrivingMin: Double = 0
        
        return DriverFeatures(
            totalTrips: totalTrips,
            totalDistance: totalDistance,
            totalHours: totalMinutes / 60.0,
            averageSpeed: avgSpeed,
            totalBrakings: totalBrakings,
            totalAccelerations: totalAccelerations,
            totalCornerings: totalCornerings,
            totalPhoneUsageMin: totalPhoneUsageMin,
            totalSpeedingKm: totalSpeedingKm,
            totalNightDrivingMin: totalNightDrivingMin
        )
    }
    
    // MARK: - 衍生指标（给 PricingModel 用）

    /// 每次行程的“等效超速事件数”（用超速里程 / 次数近似）
    var speedingEventsPerTrip: Double {
        guard totalTrips > 0 else { return 0 }
        // 这里只是一个 proxy：超速里程越大、trip 越少 → 单次 trip 风险越高
        return totalSpeedingKm / Double(totalTrips)
    }
    
    /// 急刹车率：每 100km 的急刹次数
    var harshBrakingRate: Double {
        guard totalDistance > 0 else { return 0 }
        // totalBrakings / (总里程 / 100km)
        return Double(totalBrakings) / (totalDistance / 100.0)
    }
    
    /// 开车玩手机占总驾驶时间的比例（0–1）
    var phoneUsageRatio: Double {
        let totalMinutes = totalHours * 60.0
        guard totalMinutes > 0 else { return 0 }
        return min(totalPhoneUsageMin / totalMinutes, 1.0)
    }
    
    /// 夜间驾驶时间占总驾驶时间的比例（0–1）
    var nightDrivingRatio: Double {
        let totalMinutes = totalHours * 60.0
        guard totalMinutes > 0 else { return 0 }
        return min(totalNightDrivingMin / totalMinutes, 1.0)
    }
    
    // MARK: - 驾驶评分（0–100，跟 PricingModel 里的 riskScore 相反）
    func calculateDrivingScore() -> Double {
        var score: Double = 100
        
        // 平均速度惩罚：> 90km/h 开始扣分
        if averageSpeed > 90 {
            let over = averageSpeed - 90
            score -= min(over * 0.5, 20)
        }
        
        // 急刹 / 急加速 / 急转弯
        let events = Double(totalBrakings + totalAccelerations + totalCornerings)
        score -= min(events * 0.8, 25)
        
        // 超速里程
        score -= min(totalSpeedingKm * 0.5, 20)
        
        // 开车玩手机
        score -= min(totalPhoneUsageMin * 1.0, 20)
        
        // 行驶得多且稳定给一点加分
        if totalDistance > 100 {
            score += min((totalDistance - 100) * 0.02, 5)
        }
        
        return max(0, min(100, score))
    }
}
