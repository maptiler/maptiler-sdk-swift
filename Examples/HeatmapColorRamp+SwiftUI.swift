//
//  HeatmapColorRamp+SwiftUI.swift
//  MapTilerSDK Examples
//

import SwiftUI
import MapTilerSDK

/// Demonstrates using MTHeatmapLayerHelper with a ColorRamp preset.
/// Uses the earthquakes sample GeoJSON hosted online.
struct HeatmapColorRampExample: View {
    @State private var referenceStyle: MTMapReferenceStyle = .dataviz
    @State private var styleVariant: MTMapStyleVariant? = .dark
    @State private var mapView = MTMapView(options: MTMapOptions(zoom: 1.2))

    // Note: Best practice is to set the API key at app startup (App/Scene or AppDelegate).
    // It's set here for standalone copy-paste convenience.
    init() {
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }
    }

    var body: some View {
        MTMapViewContainer(map: mapView) {}
            .referenceStyle(referenceStyle)
            .styleVariant(styleVariant)
            .didInitialize { Task { await addHeatmap() } }
    }

    private func addHeatmap() async {
        guard let style = mapView.style else { return }

        // Start from TURBO preset, make the start transparent for smoother ramp-in.
        var ramp = MTColorRamp.preset(.turbo)
        do {
            ramp = try await ramp.transparentStart(in: mapView)
        } catch { /* non-fatal in example */ }

        // Use the remote earthquakes dataset and drive intensity by the `mag` property.
        let options = MTHeatmapLayerOptions(
            data: "https://docs.maptiler.com/sdk-js/assets/earthquakes.geojson",
            property: "mag",
            radius: 25,
            opacity: 0.85,
            zoomCompensation: true
        )

        let helper = MTHeatmapLayerHelper(style)
        await helper.addHeatmap(options, colorRamp: ramp, in: mapView)
    }
}
