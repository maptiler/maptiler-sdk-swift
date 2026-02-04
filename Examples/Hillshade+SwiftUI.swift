//
//  Hillshade+SwiftUI.swift
//  MapTilerSDK Examples
//

import SwiftUI
import MapTilerSDK

/// Demonstrates adding a hillshade layer sourced from Terrain RGB DEM tiles.
struct HillshadeExample: View {
    @State private var referenceStyle: MTMapReferenceStyle = .basic
    @State private var styleVariant: MTMapStyleVariant? = .defaultVariant
    @State private var mapView = MTMapView(options: MTMapOptions(zoom: 3.0))

    init() {
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }
    }

    var body: some View {
        MTMapViewContainer(map: mapView) {}
            .referenceStyle(referenceStyle)
            .styleVariant(styleVariant)
            .didInitialize { Task { await addHillshade() } }
    }

    private func addHillshade() async {
        guard let style = mapView.style else { return }

        guard let apiKey = await MTConfig.shared.getAPIKey() else { return }

        guard let url = URL(
            string: "https://api.maptiler.com/tiles/terrain-rgb-v2/tiles.json?key=\(apiKey)"
        ) else { return }

        let dem = MTRasterDEMSource(identifier: "hillshadeSource", url: url)

        do {
            try await style.addSource(dem)

            var hills = MTHillshadeLayer(identifier: "hills", sourceIdentifier: dem.identifier)
            hills.visibility = .visible
            hills.shadowColor = UIColor(hex: "#473B24")

            try await style.addLayer(hills)
        } catch {
            print("Failed to add hillshade: \(error)")
        }
    }
}
