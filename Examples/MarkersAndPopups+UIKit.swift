//
//  MarkersAndPopups+UIKit.swift
//  MapTilerSDK
//

import UIKit
import CoreLocation
import MapTilerSDK

class MarkersAndPopupsMapViewController: UIViewController {
    enum Constants {
        static let unterageriCoordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
        static let defaultZoomLevel = 2.0
        static let markerImage = UIImage(named: "maptiler-marker")

        static let coordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 51.509865, longitude: -0.118092),
            CLLocationCoordinate2D(latitude: 48.864716, longitude: 2.349014),
            CLLocationCoordinate2D(latitude: 35.652832, longitude: 139.839478),
            CLLocationCoordinate2D(latitude: -33.918861, longitude: 18.423300),
            CLLocationCoordinate2D(latitude: 25.7616815, longitude: -80.191788)
        ]
    }

    var mapView: MTMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }
        initializeMapView()
    }

    private func initializeMapView() {
        let options = MTMapOptions(
            center: Constants.unterageriCoordinates,
            zoom: Constants.defaultZoomLevel,
            bearing: 1.0,
            pitch: 20.0
        )
        mapView = MTMapView(frame: view.frame, options: options, referenceStyle: .basic)
        mapView.delegate = self

        view.addSubview(mapView)
    }

    fileprivate func addPOIs() {
        let unterageriPopup = MTTextPopup(coordinates: Constants.unterageriCoordinates, text: "MapTiler", offset: 20.0)
        let unterageriMarker = MTMarker(coordinates: Constants.unterageriCoordinates, popup: unterageriPopup)
        unterageriMarker.draggable = true

        mapView.addMarker(unterageriMarker)

        var markers: [MTMarker] = []

        for coordinate in Constants.coordinates {
            let marker = MTMarker(coordinates: coordinate)
            marker.icon = Constants.markerImage // Can be ommited if using addMarkers:_ withSingleIcon

            markers.append(marker)
        }

        mapView.addMarkers(markers, withSingleIcon: Constants.markerImage)
    }
}

extension MarkersAndPopupsMapViewController: MTMapViewDelegate {
    func mapViewDidInitialize(_ mapView: MTMapView) {
        addPOIs()
    }

    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?) {
        if event == .isReady {
            print("Map fully loaded.")
        }
    }
}
