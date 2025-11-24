//
//  DailyStatsResponse.swift
//  WilsonTelematicsInsurance
//
//  Created by WIlson's macbook on 11/23/25.
//


//
//  DailyStat.swift
//  WilsonTelematicsInsurance
//

import Foundation

struct DailyStatsResponse: Decodable {
    let days: [DailyStat]
    let count: Int
}

struct DailyStat: Decodable, Identifiable {
    var id: String { date }  // unique per day
    
    let date: String
    let mileageKm: Double
    let tripsCount: Int
    let avgSpeedKmh: Double
    let maxSpeedKmh: Double
    let speedingKm: Double
    let accelerationsCount: Int
    let brakingsCount: Int
    let corneringsCount: Int
    let phoneUsageMin: Double
    let drivingTimeMin: Double
    let nightDrivingMin: Double
    let rushHourDrivingMin: Double
}
