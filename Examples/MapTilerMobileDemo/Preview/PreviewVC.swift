//
//  PreviewVC.swift
//  MapTilerMobileDemo
//

import UIKit
import MapTilerSDK
import CoreLocation

class PreviewVC: UIViewController {
    enum Constants {
        static let unterageriCoordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
    }

    @IBOutlet weak var contentView: UIView!

    var mapView: MTMapView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mapView.frame = contentView.frame
        contentView.addSubview(mapView)

        mapView.delegate = self
    }

    @IBAction func closeButtonTouchUpInside(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension PreviewVC: MTMapViewDelegate {
    func mapView(_ mapView: MapTilerSDK.MTMapView, didTriggerEvent event: MapTilerSDK.MTEvent, with data: MapTilerSDK.MTData?) {
        // Empty block
    }
    
    func mapViewDidInitialize(_ mapView: MapTilerSDK.MTMapView) {
        let marker = MTMarker(coordinates: Constants.unterageriCoordinates, icon: UIImage(named: "maptiler-marker"), draggable: true)
        mapView.addMarker(marker)
    }
}
