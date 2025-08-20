//
//  PolygonLayerHelper+UIKit.swift
//  MapTilerSDK Examples
//

import UIKit
import CoreLocation
import MapTilerSDK

class PolygonLayerHelperViewController: UIViewController {
    enum Constants {
        static let center = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
        static let defaultZoomLevel = 9.0
    }

    var mapView: MTMapView!
    private var polygonHelper: MTPolygonLayerHelper?

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
    }

    private func initializeMapView() {
        let options = MTMapOptions(center: Constants.center, zoom: Constants.defaultZoomLevel, bearing: 0.0, pitch: 0.0)
        mapView = MTMapView(frame: view.frame, options: options, referenceStyle: .basic)
        mapView.delegate = self
        view.addSubview(mapView)
    }

    private func addPolygonLayer() {
        let base = Constants.center
        // Simple square around center ~0.02 degrees
        let d = 0.02
        let ring: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: base.latitude + d, longitude: base.longitude - d),
            CLLocationCoordinate2D(latitude: base.latitude + d, longitude: base.longitude + d),
            CLLocationCoordinate2D(latitude: base.latitude - d, longitude: base.longitude + d),
            CLLocationCoordinate2D(latitude: base.latitude - d, longitude: base.longitude - d)
        ]

        let polygon = MTPolygonLayerHelper.Polygon(outer: ring)
        let options = MTPolygonLayerHelper.Options(
            fillColor: .systemBlue,
            outlineColor: .black,
            opacity: 0.5,
            shouldBeAntialiased: true,
            visibility: .visible,
            minZoom: nil,
            maxZoom: nil
        )

        Task { [weak self] in
            guard let self else { return }
            do {
                self.polygonHelper = try await MTPolygonLayerHelper.create(
                    on: self.mapView,
                    polygons: [polygon],
                    options: options
                )

                // Demonstrate updating geometry after a short delay
                try await Task.sleep(nanoseconds: 2_000_000_000)

                let d2 = 0.03
                let newRing: [CLLocationCoordinate2D] = [
                    CLLocationCoordinate2D(latitude: base.latitude + d2, longitude: base.longitude - d2),
                    CLLocationCoordinate2D(latitude: base.latitude + d2, longitude: base.longitude + d2),
                    CLLocationCoordinate2D(latitude: base.latitude - d2, longitude: base.longitude + d2),
                    CLLocationCoordinate2D(latitude: base.latitude - d2, longitude: base.longitude - d2)
                ]
                await self.polygonHelper?.setPolygons([.init(outer: newRing)])
            } catch {
                print("Polygon helper creation failed: \(error)")
            }
        }
    }

    private func addPolygonLayerFromURL() {
        // Demonstrates the simplified helpers API (mirrors JS helpers.addPolygon)
        guard let url = URL(string: "https://docs.maptiler.com/sdk-js/assets/us_states.geojson") else { return }

        Task { [weak self] in
            guard let self else { return }
            do {
                self.polygonHelper = try await MTHelpers.addPolygon(on: self.mapView, options: .init(
                    data: url,
                    fillOpacity: 0.5,
                    fillColor: .systemGreen,
                    fillOutlineColor: .darkGray
                ))

                // Switch URL after a short delay (for demo purposes)
                try await Task.sleep(nanoseconds: 2_000_000_000)
                if let url2 = URL(string: "https://docs.maptiler.com/sdk-js/assets/earthquakes.geojson") {
                    await self.polygonHelper?.setURL(url2)
                }
            } catch {
                print("helpers.addPolygon failed: \(error)")
            }
        }
    }
}

extension PolygonLayerHelperViewController: MTMapViewDelegate {
    func mapViewDidInitialize(_ mapView: MTMapView) {
        // No-op. Style is set via MTMapView initializer.
    }

    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?) {
        // Wait for map readiness before touching style
        if event == .isReady {
            // Choose one of the demos:
            addPolygonLayer()
            // addPolygonLayerFromURL()
        }
    }
}
