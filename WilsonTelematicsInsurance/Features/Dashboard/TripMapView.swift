//
//  TripMapView.swift
//  WilsonTelematicsInsurance
//

import SwiftUI
import MapKit

struct TripMapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    let events: [MapEventPoint]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.isRotateEnabled = false
        mapView.pointOfInterestFilter = .includingAll
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 清除旧的 overlays / annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        guard !coordinates.isEmpty else { return }

        // 1. 添加路线折线（蓝色）
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)

        // 2. 起点 / 终点 annotation
        if let first = coordinates.first {
            let start = StartEndAnnotation(coordinate: first, isStart: true)
            mapView.addAnnotation(start)
        }
        if let last = coordinates.last {
            let end = StartEndAnnotation(coordinate: last, isStart: false)
            mapView.addAnnotation(end)
        }

        // 3. 事件点 annotations
        for event in events {
            let ann = EventAnnotation(
                coordinate: event.coordinate,
                kind: event.kind
            )
            mapView.addAnnotation(ann)
        }

        // 4. 调整可视区域
        mapView.showAnnotations(mapView.annotations, animated: false)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {

        // 路线样式：蓝色线条
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.lineWidth = 4
                renderer.strokeColor = .systemBlue
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        // 各种 annotation 样式
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // 系统自己的用户定位点，直接用默认
            if annotation is MKUserLocation {
                return nil
            }

            // 起点 / 终点
            if let startEnd = annotation as? StartEndAnnotation {
                let identifier = "StartEnd"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view?.canShowCallout = true
                } else {
                    view?.annotation = annotation
                }

                if startEnd.isStart {
                    view?.markerTintColor = .systemGreen
                    view?.glyphText = "A"
                    view?.titleVisibility = .adaptive
                    view?.subtitleVisibility = .adaptive
                } else {
                    view?.markerTintColor = .systemRed
                    view?.glyphText = "B"
                    view?.titleVisibility = .adaptive
                    view?.subtitleVisibility = .adaptive
                }

                return view
            }

            // 事件点
            if let eventAnn = annotation as? EventAnnotation {
                let identifier = "EventPoint"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view?.canShowCallout = true
                } else {
                    view?.annotation = annotation
                }

                // 根据事件类型区分颜色
                let kind = eventAnn.kind.lowercased()
                switch kind {
                case "braking":
                    view?.markerTintColor = .systemOrange
                    view?.glyphText = "B"
                case "acceleration":
                    view?.markerTintColor = .systemBlue
                    view?.glyphText = "A"
                case "cornering":
                    view?.markerTintColor = .systemPurple
                    view?.glyphText = "C"
                case "phone":
                    view?.markerTintColor = .systemPink
                    view?.glyphText = "P"
                default:
                    view?.markerTintColor = .darkGray
                    view?.glyphText = "!"
                }

                return view
            }

            return nil
        }
    }
}

// MARK: - 自定义 Annotation 类型

/// 起点 / 终点
final class StartEndAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let isStart: Bool

    init(coordinate: CLLocationCoordinate2D, isStart: Bool) {
        self.coordinate = coordinate
        self.isStart = isStart
        super.init()
    }

    var title: String? {
        isStart ? "start" : "end"
    }
}

/// 事件点（harsh / phone 等）
final class EventAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let kind: String

    init(coordinate: CLLocationCoordinate2D, kind: String) {
        self.coordinate = coordinate
        self.kind = kind
        super.init()
    }

    var title: String? {
        switch kind.lowercased() {
        case "braking": return "braking"
        case "acceleration": return "acceleration"
        case "cornering": return "cornering"
        case "phone": return "phone usage"
        default: return "event"
        }
    }
}
