//
//  SourcesAndLayers+UIKit.swift
//  MapTilerSDK
//

import UIKit
import CoreLocation
import MapTilerSDK

class SourcesAndLayersMapViewController: UIViewController {
    enum Constants {
        static let unterageriCoordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
        static let defaultZoomLevel = 2.0
    }

    var mapView: MTMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeMapView()
    }

    private func initializeMapView() {
        let options = MTMapOptions(center: Constants.unterageriCoordinates, zoom: Constants.defaultZoomLevel, bearing: 1.0, pitch: 20.0)
        mapView = MTMapView(frame: view.frame, options: options, referenceStyle: .basic)
        mapView.delegate = self

        view.addSubview(mapView)
    }

    fileprivate func addContours() {
        guard let style = mapView.style else {
            return
        }

        if let contoursTilesURL = URL(string: "https://api.maptiler.com/tiles/contours-v2/{z}/{x}/{y}.pbf?key=YOUR_API_KEY") {
            let contoursDataSource = MTVectorTileSource(identifier: "contoursSource", tiles: [contoursTilesURL])
            style.addSource(contoursDataSource)

            let contoursLayer = MTLineLayer(identifier: "contoursLayer", sourceIdentifier: contoursDataSource.identifier, sourceLayer: "contour_ft")
            contoursLayer.color = .brown
            contoursLayer.width = 2.0

            style.addLayer(contoursLayer)
        }
    }
}

extension SourcesAndLayersMapViewController: MTMapViewDelegate {
    func mapViewDidInitialize(_ mapView: MTMapView) {
        addContours()
    }

    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?) {
        if event == .sourceDidUpdate {
            print("Source Updated")
        }
    }
}
