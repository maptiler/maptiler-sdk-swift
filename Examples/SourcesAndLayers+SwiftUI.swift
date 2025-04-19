//
//  SourcesAndLayers+SwiftUI.swift
//  MapTilerSDK
//

import SwiftUI
import CoreLocation
import MapTilerSDK

struct SourcesAndLayersMapView: View {
    enum Constants {
        static let unterageriCoordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
        static let defaultZoomLevel = 2.0
    }

    let contoursSourceID = "contoursSource"
    let airportsSourceID = "airportsSource"

    let contoursTilesURL = URL(string: "https://api.maptiler.com/tiles/contours-v2/{z}/{x}/{y}.pbf?key=YOUR_API_KEY") ?? URL.documentsDirectory

    @State private var referenceStyle: MTMapReferenceStyle = .basic
    @State private var styleVariant: MTMapStyleVariant? = .defaultVariant

    @State private var mapView = MTMapView(options: MTMapOptions(zoom: Constants.defaultZoomLevel))

    var body: some View {
        MTMapViewContainer(map: mapView) {
            MTVectorTileSource(identifier: contoursSourceID, tiles: [contoursTilesURL])

            MTLineLayer(identifier: "contoursLayer", sourceIdentifier: contoursSourceID, sourceLayer: "contour_ft")
                .color(.brown)
                .width(2.0)

        }
            .referenceStyle(referenceStyle)
            .styleVariant(styleVariant)
    }
}
