//
//  PointBasic+SwiftUI.swift
//  MapTilerSDK Examples
//

import SwiftUI
import MapTilerSDK

/// Demonstrates a basic point layer using MTPointLayerHelper
/// with solid color, outline and optional labels.
struct PointBasicExample: View {
    @State private var referenceStyle: MTMapReferenceStyle = .basic
    @State private var styleVariant: MTMapStyleVariant? = .defaultVariant
    @State private var mapView = MTMapView(options: MTMapOptions(zoom: 1.6))

    // Note: Best practice is to set the API key at app startup (App/Scene or AppDelegate).
    // It's set here for standalone copy-paste convenience.
    init() {
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }
    }

    var body: some View {
        MTMapViewContainer(map: mapView) {}
            .referenceStyle(referenceStyle)
            .styleVariant(styleVariant)
            .didInitialize { Task { await addPoints() } }
    }

    private func addPoints() async {
        guard let style = mapView.style else { return }

        // Use the public earthquakes sample GeoJSON (points) as data.
        let options = MTPointLayerOptions(
            data: "https://docs.maptiler.com/sdk-js/assets/earthquakes.geojson",
            // Use a solid color, fixed radius, and subtle white outline.
            pointColor: "#1e90ff",
            pointRadius: 6,
            pointOpacity: 0.9,
            outline: true,
            outlineColor: "white",
            outlineWidth: 1,
            outlineOpacity: 0.9,
            // Optional labels driven by a feature property, if present
            showLabel: false,
            labelColor: "white",
            labelSize: 11,
            // Enable clustering to make dense datasets clearer at low zooms
            cluster: true,
            zoomCompensation: true
        )

        let helper = MTPointLayerHelper(style)
        await helper.addPoint(options)
    }
}
