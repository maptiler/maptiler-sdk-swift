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

    @State private var referenceStyle: MTMapReferenceStyle = .basic
    @State private var styleVariant: MTMapStyleVariant? = .defaultVariant

    @State private var mapView = MTMapView(options: MTMapOptions(zoom: Constants.defaultZoomLevel))

    var body: some View {
        MTMapViewContainer(map: mapView) {
            let unterageriPopup = MTTextPopup(coordinates: unterageriCoordinates, text: "MapTiler", offset: 20.0)

            MTMarker(coordinates: unterageriCoordinates, draggable: true, popup: unterageriPopup)
        }
            .referenceStyle(referenceStyle)
            .styleVariant(styleVariant)
    }
}
