//
//  PolygonLayerHelper+SwiftUI.swift
//  MapTilerSDK Examples
//

import SwiftUI
import CoreLocation
import MapTilerSDK

struct PolygonHelperSwiftUIExample: View {
    @State private var mapView = MTMapView(options: MTMapOptions(zoom: 4.0))
    @State private var polygonHelper: MTPolygonLayerHelper?

    var body: some View {
        MTMapViewContainer(map: mapView) {}
            .referenceStyle(.basic)
            .styleVariant(.defaultVariant)
            .didTriggerEvent { event, _ in
                if event == .isReady {
                    addPolygonFromURL()
                }
            }
    }

    private func addPolygonFromURL() {
        guard let url = URL(string: "https://docs.maptiler.com/sdk-js/assets/us_states.geojson") else { return }
        Task {
            do {
                polygonHelper = try await MTHelpers.addPolygon(on: mapView, options: .init(
                    data: url,
                    fillOpacity: 0.5,
                    fillColor: .systemBlue,
                    fillOutlineColor: .black
                ))
            } catch {
                print("helpers.addPolygon failed: \(error)")
            }
        }
    }
}

