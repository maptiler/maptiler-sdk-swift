//
//  MainViewController.swift
//  MapTilerMobileDemo
//

import UIKit
import MapTilerSDK

class MainViewController: UIViewController {
    @IBOutlet weak var mapView: MTMapView! {
        didSet {
            mapView.delegate = self
        }
    }

    @IBOutlet weak var mapControlView: MapControlView! {
        didSet {
            mapControlView.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MainViewController: MapControlViewDelegate {
    func mapControlViewDidTapZoomIn(_ mapControlView: MapControlView) {
        Task {
            await mapView.zoomIn()
        }
    }
    
    func mapControlViewDidTapZoomOut(_ mapControlView: MapControlView) {
        Task {
            await mapView.zoomOut()
        }
    }

    func mapControlView(_ mapControlView: MapControlView, didSelectBearing bearing: Double) {
        Task {
            await mapView.setBearing(bearing)
        }
    }
}

extension MainViewController: MTMapViewDelegate {
    func mapViewDidInitialize(_ mapView: MTMapView) {
        print("-------------------------")
        print(">>> MapTiler SDK Demo <<<")
        print("--- Map Initialized ---")
        print("-------------------------")
    }

    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent) {
        print(">>> Event Propagation Demo <<<")
        print("Event Triggered: \(event.rawValue)")
        print("------------------------------")
    }
}

extension MainViewController: MTMapViewDelegate {
    func mapViewDidInitialize(_ mapView: MTMapView) {
        print("-------------------------")
        print(">>> MapTiler SDK Demo <<<")
        print("--- Map Initialized ---")
        print("-------------------------")
    }

    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent) {
        print(">>> Event Propagation Demo <<<")
        print("Event Triggered: \(event.rawValue)")
        print("------------------------------")
    }
}
