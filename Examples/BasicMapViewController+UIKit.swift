//
//  BasicMapView+UIKit.swift
//  MapTilerSDK
//

import UIKit
import CoreLocation
import MapTilerSDK

class BasicMapViewController: UIViewController {
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

    private func zoomIn() {
        mapView.zoomIn()
    }

    private func zoomOut() {
        mapView.zoomOut()
    }
}

extension BasicMapViewController: MTMapViewDelegate {
    func mapViewDidInitialize(_ mapView: MTMapView) {
        mapView.style?.setStyle(.basic, styleVariant: .defaultVariant)
    }

    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?) {
        if event == .didDoubleTap {
            mapView.setRoll(6.0)
        }
    }
}
