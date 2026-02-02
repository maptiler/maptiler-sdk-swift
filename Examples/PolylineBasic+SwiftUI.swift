//
//  PolylineBasic+SwiftUI.swift
//  MapTilerSDK Examples
//

import SwiftUI
import MapTilerSDK

/// Demonstrates a basic polyline layer using MTPolylineLayerHelper
/// with solid color, width, and optional outline/dash.
struct PolylineBasicExample: View {
    @State private var referenceStyle: MTMapReferenceStyle = .basic
    @State private var styleVariant: MTMapStyleVariant? = .defaultVariant
    @State private var mapView = MTMapView(options: MTMapOptions(zoom: 2.0))

    // Note: Best practice is to set the API key at app startup (App/Scene or AppDelegate).
    // It's set here for standalone copy-paste convenience.
    init() {
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }
    }

    var body: some View {
        MTMapViewContainer(map: mapView) {}
            .referenceStyle(referenceStyle)
            .styleVariant(styleVariant)
            .didInitialize { Task { await addLines() } }
    }

    private func addLines() async {
        guard let style = mapView.style else { return }

        // Inline sample GeoJSON with a couple of LineStrings
        let lineGeoJSON = """
        {
        "type": "FeatureCollection",
        "features": [
        {
        "type": "Feature",
        "properties": { "name": "Example Route A" },
        "geometry": {
        "type": "LineString",
        "coordinates": [
        [-122.4194, 37.7749],
        [-118.2437, 34.0522],
        [-112.0740, 33.4484]
        ]
        }
        },
        {
        "type": "Feature",
        "properties": { "name": "Example Route B" },
        "geometry": {
        "type": "LineString",
        "coordinates": [
        [2.3522, 48.8566],
        [12.4964, 41.9028],
        [19.0402, 47.4979]
        ]
        }
        }
        ]
        }
        """

        let options = MTPolylineLayerOptions(
            data: lineGeoJSON,
            lineColor: "#ff7f50",
            lineWidth: 3.0,
            lineOpacity: 0.95,
            lineDashArray: .pattern("__ __ __ __"),
            outline: true,
            outlineColor: "#202020",
            outlineWidth: 1.0,
            outlineOpacity: 0.8
        )

        let helper = MTPolylineLayerHelper(style)
        await helper.addPolyline(options)
    }
}
