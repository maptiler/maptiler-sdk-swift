//
//  HeatmapBasic+SwiftUI.swift
//  MapTilerSDK Examples
//

import SwiftUI
import MapTilerSDK

/// Demonstrates a basic heatmap using MTHeatmapLayerHelper
/// Uses the public earthquakes sample GeoJSON and drives weight/radius by the `mag` property.
struct HeatmapBasicExample: View {
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

        // Property-driven weight and radius using the `mag` property in the dataset
        let weightByMagnitude: MTNumberOrPropertyValues = .propertyValues([
            .init(propertyValue: 0, value: 0.2),
            .init(propertyValue: 2, value: 0.5),
            .init(propertyValue: 4, value: 0.85),
            .init(propertyValue: 6, value: 1.0)
        ])

        // Use property-driven radius; zoom compensation will scale it with zoom
        let radiusByMagnitude: MTRadiusOption = .property([
            .init(propertyValue: 0, value: 10),
            .init(propertyValue: 2, value: 18),
            .init(propertyValue: 4, value: 28),
            .init(propertyValue: 6, value: 40)
        ])

        let options = MTHeatmapLayerOptions(
            data: "https://docs.maptiler.com/sdk-js/assets/earthquakes.geojson",
            property: "mag",
            weight: weightByMagnitude,
            radius: radiusByMagnitude,
            opacity: .ramp([
                .init(zoom: 0, value: 0),
                .init(zoom: 0.5, value: 1),
                .init(zoom: 22.5, value: 1),
                .init(zoom: 23, value: 0)
            ]),
            intensity: .ramp([
                .init(zoom: 0, value: 0.05),
                .init(zoom: 4, value: 0.2),
                .init(zoom: 16, value: 1)
            ]),
            zoomCompensation: true
        )

        let helper = MTHeatmapLayerHelper(style)
        await helper.addHeatmap(options, colorRamp: nil, in: mapView)
    }
}
