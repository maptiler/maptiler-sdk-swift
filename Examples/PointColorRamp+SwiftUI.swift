//
//  PointColorRamp+SwiftUI.swift
//  MapTilerSDK Examples
//

import SwiftUI
import MapTilerSDK

/// Demonstrates using MTPointLayerHelper with a ColorRamp mapped to a property.
/// Uses the earthquakes sample GeoJSON and colors points by the `mag` property.
struct PointColorRampExample: View {
    @State private var referenceStyle: MTMapReferenceStyle = .dataviz
    @State private var styleVariant: MTMapStyleVariant? = .dark
    @State private var mapView = MTMapView(options: MTMapOptions(zoom: 1.6))

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

        // Color by magnitude using a preset color ramp.
        // For points, the ColorRamp is assigned to `pointColor` and will use the `property` below.
        let ramp = MTColorRamp.preset(.turbo)

        let options = MTPointLayerOptions(
            data: "https://docs.maptiler.com/sdk-js/assets/earthquakes.geojson",
            property: "mag",
            pointRadius: 7,
            pointOpacity: 0.95,
            outline: true,
            outlineColor: "#101010",
            outlineWidth: 0.75,
            outlineOpacity: 0.85,
            cluster: false,
            zoomCompensation: true
        )

        let helper = MTPointLayerHelper(style)
        await helper.addPoint(options, colorRamp: ramp, in: mapView)
    }
}
