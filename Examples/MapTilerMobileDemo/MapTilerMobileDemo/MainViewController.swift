//
//  MainViewController.swift
//  MapTilerMobileDemo
//

import UIKit
import MapTilerSDK

class MainViewController: UIViewController {
    @IBOutlet weak var mapView: MTMapView!
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
}
