//
//  PolygonHelper+SwiftUI.swift
//  MapTilerSDK Examples
//

import SwiftUI
import MapTilerSDK

struct PolygonHelperExampleView: View {
    @State private var mapView = MTMapView(options: MTMapOptions(zoom: 3.0))

    var body: some View {
        VStack(spacing: 12) {
            MTMapViewContainer(map: mapView) {
                // No initial sources/layers; polygon will be added on button tap.
            }
            .referenceStyle(.basic)
            .styleVariant(.defaultVariant)

            HStack {
                Button("Add Polygon") {
                    Task {
                        let options = MTPolygonLayerOptions(
                            data: .geoJSON(Self.samplePolygonGeoJSON),
                            fillOpacity: 0.5,
                            outline: true,
                            outlineColor: .white,
                            outlineWidth: 2.0
                        )

                        _ = try? await MTPolygonHelper.addPolygon(on: mapView, options: options)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    /// Simple sample polygon (Lng/Lat order) near Switzerland.
    private static let samplePolygonGeoJSON = """
    {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "properties": {},
          "geometry": {
            "type": "Polygon",
            "coordinates": [
              [
                [8.5, 47.4],
                [8.9, 47.4],
                [8.9, 47.2],
                [8.5, 47.2],
                [8.5, 47.4]
              ]
            ]
          }
        }
      ]
    }
    """
}

