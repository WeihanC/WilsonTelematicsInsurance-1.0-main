//
//  TripsResponse.swift
//  WilsonTelematicsInsurance
//
//  Waypoints & events response models for /api/trips/:tripId/waypoints
//

import Foundation
import CoreLocation

// MARK: - /api/trips/:tripId/waypoints 响应模型
// 对应 Node.js 后端返回的 JSON：
// {
//   "tripId": "...",
//   "polyline": [ { "lat": Double, "lon": Double }, ... ],
//   "speedSeries": [ { "t": Double, "speedKmh": Double }, ... ],
//   "events": [ { "lat": Double, "lon": Double, "type": String }, ... ]
// }

struct TripWaypointsResponse: Codable {
    let tripId: String
    let polyline: [BackendWaypoint]
    let speedSeries: [SpeedPoint]
    let events: [BackendTripEvent]?
}

// 单个折线点（纬度/经度）
struct BackendWaypoint: Codable {
    let lat: Double
    let lon: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

// 速度时间序列点（用来画速度曲线 / 做分析）
// 本地 id 用 UUID 生成，不依赖服务器
struct SpeedPoint: Identifiable, Codable {
    var id = UUID()
    let t: Double          // 秒 since start
    let speedKmh: Double   // km/h

    enum CodingKeys: String, CodingKey {
        case t
        case speedKmh
    }
}

// 单个事件（harsh braking / acceleration / cornering / phone / speeding 等）
// ➜ 注意：这里用的是 "type"，要和 Node.js 返回的字段一致：{ lat, lon, type }
struct BackendTripEvent: Codable {
    let lat: Double
    let lon: Double
    let type: String?
}

// 给 MapKit 用的事件点模型（带坐标和类型）
struct MapEventPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let kind: String       // "phone" / "braking" / "acceleration" / "cornering" / "speeding" / "event"
}

// MARK: - 便利扩展

extension BackendTripEvent {

    /// 把后端的 event 转成地图要用的 MapEventPoint
    /// 通过 type 字符串做关键词分类
    var asMapEventPoint: MapEventPoint {
        let base = (type ?? "").lowercased()

        let mappedKind: String
        if base.contains("brak") {
            mappedKind = "braking"
        } else if base.contains("accel") {
            mappedKind = "acceleration"
        } else if base.contains("corner") || base.contains("turn") {
            mappedKind = "cornering"
        } else if base.contains("speed") {
            mappedKind = "speeding"
        } else if base.contains("phone")
                || base.contains("distract")
                || base.contains("mobile")
                || base.contains("call")
                || base.contains("text")
                || base.contains("sms") {
            // 👉 尽可能把各种“手机相关”的原始类型都归为 phone
            mappedKind = "phone"
        } else {
            mappedKind = "event"
        }

        return MapEventPoint(
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            kind: mappedKind
        )
    }
}
