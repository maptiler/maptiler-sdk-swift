//
//  MarkersAndPopups+SwiftUI.swift
//  MapTilerSDK
//

import SwiftUI
import CoreLocation
import MapTilerSDK

struct MarkersAndPopupsMapView: View {
    enum Constants {
        static let defaultZoomLevel = 2.0
    }

    let unterageriCoordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
    let brnoCoordinates = CLLocationCoordinate2D(latitude: 49.212596, longitude: 16.626576)

    @State private var referenceStyle: MTMapReferenceStyle = .basic
    @State private var styleVariant: MTMapStyleVariant? = .defaultVariant

    @State private var mapView = MTMapView(options: MTMapOptions(zoom: Constants.defaultZoomLevel))

    // Note: Best practice is to set the API key at app startup (App/Scene or AppDelegate).
    // It's set here for standalone copy-paste convenience.
    init() {
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }
    }

    var body: some View {
        MTMapViewContainer(map: mapView) {
            let unterageriPopup = MTTextPopup(coordinates: unterageriCoordinates, text: "MapTiler", offset: 20.0)

            MTMarker(coordinates: unterageriCoordinates, draggable: true, popup: unterageriPopup)
        }
            .referenceStyle(referenceStyle)
            .styleVariant(styleVariant)
            .didInitialize {
                let marker = MTMarker(coordinates: brnoCoordinates)

                Task {
                    await mapView.addMarker(marker)
                }
            }
    }
}
