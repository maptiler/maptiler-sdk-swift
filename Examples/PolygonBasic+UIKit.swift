//
//  PolygonBasic+UIKit.swift
//  MapTilerSDK Examples
//

import UIKit
import MapTilerSDK

/// Demonstrates a basic polygon layer using MTPolygonLayerHelper
/// with fill color/opacity and outlined borders.
final class PolygonBasicUIKitExampleViewController: UIViewController {
    private var mapView: MTMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }

        let options = MTMapOptions(zoom: 1.8)
        mapView = MTMapView(frame: view.bounds, options: options, referenceStyle: .basic, styleVariant: .defaultVariant)
        view.addSubview(mapView)

        Task { await addPolygons() }
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
