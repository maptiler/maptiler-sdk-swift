//
//  MainViewController.swift
//  MapTilerMobileDemo
//

import UIKit
import CoreLocation
import SwiftUI
import Combine
import MapTilerSDK

class MainViewController: UIViewController {
    enum Constants {
        static let unterageriCoordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
        static let brnoCoordinates = CLLocationCoordinate2D(latitude: 49.212596, longitude: 16.626576)
        static let defaultZoomLevel = 14.0
    }

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

    @IBOutlet weak var jumpContainerView: UIView!

    private var dataModel = JumpDataModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpJumpView()
    }

    private func setUpJumpView() {
        let jumpHostingController = UIHostingController(rootView: JumpView(dataModel: dataModel))
        addChild(jumpHostingController)

        jumpHostingController.view.backgroundColor = .clear
        jumpHostingController.view.frame = jumpContainerView.bounds
        jumpContainerView.addSubview(jumpHostingController.view)

        jumpHostingController.didMove(toParent: self)

        observeJumpCoordinates()
    }

    private func observeJumpCoordinates() {
        dataModel.$jumpCoordinates
            .compactMap{ $0 }
            .sink { [weak self] coordinates in
                self?.jumpTo(coordinates)
            }
            .store(in: &cancellables)
    }

    private func jumpTo(_ coordinates: CLLocationCoordinate2D) {
        Task {
            await mapView.jumpTo(coordinates, options: nil)
        }
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

    func mapControlViewDidTapFlyTo(_ mapControlView: MapControlView) {
        Task {
            let unterageriCoordinates: CLLocationCoordinate2D = Constants.unterageriCoordinates

            await mapView.flyTo(unterageriCoordinates, options: nil)

            dataModel.latitude = unterageriCoordinates.latitude
            dataModel.longitude = unterageriCoordinates.longitude
        }
    }

    func mapControlViewDidTapEaseTo(_ mapControlView: MapControlView) {
        Task {
            let brnoCoordinates: CLLocationCoordinate2D = Constants.brnoCoordinates
            let options = MTCameraOptions(zoom: Constants.defaultZoomLevel)

            await mapView.easeTo(brnoCoordinates, options: options)

            dataModel.latitude = brnoCoordinates.latitude
            dataModel.longitude = brnoCoordinates.longitude
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
