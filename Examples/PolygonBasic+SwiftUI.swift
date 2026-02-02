//
//  PolygonBasic+SwiftUI.swift
//  MapTilerSDK Examples
//

import SwiftUI
import MapTilerSDK

/// Demonstrates a basic polygon layer using MTPolygonLayerHelper
/// with fill color/opacity and outlined borders.
struct PolygonBasicExample: View {
    @State private var referenceStyle: MTMapReferenceStyle = .basic
    @State private var styleVariant: MTMapStyleVariant? = .defaultVariant
    @State private var mapView = MTMapView(options: MTMapOptions(zoom: 1.8))

    // Note: Best practice is to set the API key at app startup (App/Scene or AppDelegate).
    // It's set here for standalone copy-paste convenience.
    init() {
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }
    }

    var body: some View {
        MTMapViewContainer(map: mapView) {}
            .referenceStyle(referenceStyle)
            .styleVariant(styleVariant)
            .didInitialize { Task { await addPolygons() } }
    }

    private func addPolygons() async {
        guard let style = mapView.style else { return }

        // Inline sample GeoJSON with two simple polygons
        let polygonGeoJSON = """
        {
        "type": "FeatureCollection",
        "features": [
        {
        "type": "Feature",
        "properties": { "name": "Example Area A" },
        "geometry": {
        "type": "Polygon",
        "coordinates": [[
        [-3.0, 52.0],
        [2.0, 52.0],
        [2.0, 55.0],
        [-3.0, 55.0],
        [-3.0, 52.0]
        ]]
        }
        },
        {
        "type": "Feature",
        "properties": { "name": "Example Area B" },
        "geometry": {
        "type": "Polygon",
        "coordinates": [[
        [100.0, 12.0],
        [105.0, 12.0],
        [105.0, 16.5],
        [100.0, 16.5],
        [100.0, 12.0]
        ]]
        }
        }
        ]
        }
        """

        let options = MTPolygonLayerOptions(
            data: polygonGeoJSON,
            fillColor: "#32cd32",
            fillOpacity: 0.5,
            outline: true,
            outlineColor: "white",
            outlineWidth: 1.5,
            outlineOpacity: 0.9
        )

        let helper = MTPolygonLayerHelper(style)
        await helper.addPolygon(options)
    }
}
