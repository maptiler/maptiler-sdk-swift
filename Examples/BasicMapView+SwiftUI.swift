//
//  BasicMapView+SwiftUI.swift
//  MapTilerSDK
//

import SwiftUI
import CoreLocation
import MapTilerSDK

struct BasicMapView: View {
    enum Constants {
        static let unterageriCoordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
        static let defaultZoomLevel = 2.0
    }

    @State private var referenceStyle: MTMapReferenceStyle = .basic
    @State private var styleVariant: MTMapStyleVariant? = .defaultVariant

    @State private var mapView = MTMapView(options: MTMapOptions(zoom: Constants.defaultZoomLevel))

    var body: some View {
        MTMapViewContainer(map: mapView) {}
            .referenceStyle(referenceStyle)
            .styleVariant(styleVariant)
            .didTriggerEvent { event, _ in
                if event == .didDoubleTap {
                    Task {
                        await mapView.setRoll(6.0)
                    }
                }
            }

        HStack {
            Button("Zoom In") {
                Task {
                    await mapView.zoomIn()
                }
            }

            Button("Zoom Out") {
                Task {
                    await mapView.zoomOut()
                }
            }
        }
    }
}
