//
//  Converters+SwiftUI.swift
//  MapTilerSDK Examples
//

import SwiftUI
import MapTilerSDK

/// Demonstrates using MTMapView converters to transform GPX and KML
/// strings into GeoJSON, then render them via polyline/polygon helpers.
struct ConvertersExample: View {
    @State private var referenceStyle: MTMapReferenceStyle = .basic
    @State private var styleVariant: MTMapStyleVariant? = .defaultVariant
    @State private var mapView = MTMapView(options: MTMapOptions(zoom: 2.0))

    init() {
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }
    }

    var body: some View {
        MTMapViewContainer(map: mapView) {}
            .referenceStyle(referenceStyle)
            .styleVariant(styleVariant)
            .didInitialize { Task { await addConvertedLayers() } }
    }

    private func addConvertedLayers() async {
        guard let style = mapView.style else { return }

        // Minimal GPX with a single track containing a few points
        let sampleGPX = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="MapTilerSDK">
        <trk>
        <name>Sample GPX Track</name>
        <trkseg>
        <trkpt lat="48.8566" lon="2.3522"></trkpt>
        <trkpt lat="50.1109" lon="8.6821"></trkpt>
        <trkpt lat="52.5200" lon="13.4050"></trkpt>
        </trkseg>
        </trk>
        </gpx>
        """

        // Minimal KML with one polygon
        let sampleKML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
        <Document>
        <Placemark>
        <name>Sample KML Polygon</name>
        <Polygon>
        <outerBoundaryIs>
        <LinearRing>
        <coordinates>
        -74.02,40.70,0 -73.90,40.70,0 -73.90,40.80,0 -74.02,40.80,0 -74.02,40.70,0
        </coordinates>
        </LinearRing>
        </outerBoundaryIs>
        </Polygon>
        </Placemark>
        </Document>
        </kml>
        """

        do {
            // Convert using MTMapView helpers
            let gpxAsGeoJSON = try await mapView.convertGPXToGeoJSON(sampleGPX)
            let kmlAsGeoJSON = try await mapView.convertKMLToGeoJSON(sampleKML)

            // Render the converted GPX as a polyline
            let lineOptions = MTPolylineLayerOptions(
                data: gpxAsGeoJSON,
                lineColor: "#ff4500",
                lineWidth: 3.0,
                lineOpacity: 0.95,
                outline: true,
                outlineColor: "#101010",
                outlineWidth: 1.0,
                outlineOpacity: 0.8
            )

            // Render the converted KML as a filled polygon
            let polygonOptions = MTPolygonLayerOptions(
                data: kmlAsGeoJSON,
                fillColor: "#1e90ff",
                fillOpacity: 0.5,
                outline: true,
                outlineColor: "white",
                outlineWidth: 1.2,
                outlineOpacity: 0.9
            )

            let lineHelper = MTPolylineLayerHelper(style)
            let polygonHelper = MTPolygonLayerHelper(style)
            await lineHelper.addPolyline(lineOptions)
            await polygonHelper.addPolygon(polygonOptions)
        } catch {
            print("Conversion failed: \(error)")
        }
    }
}
