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

    @IBOutlet weak var mapZoomControlView: MapZoomControlView! {
        didSet {
            mapZoomControlView.delegate = self
        }
    }

    @IBOutlet weak var jumpContainerView: UIView!
    @IBOutlet weak var benchmarkButton: UIButton!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    private var dataModel = JumpDataModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpJumpView()

        setUpLoadingActivityIndicator()
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

    private func setUpLoadingActivityIndicator() {
        loadingActivityIndicator.startAnimating()
        loadingActivityIndicator.hidesWhenStopped = true
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
    func mapControlViewDidTapFlyTo(_ mapControlView: MapControlView) {
        Task {
            let unterageriCoordinates: CLLocationCoordinate2D = Constants.unterageriCoordinates

            await mapView.flyTo(unterageriCoordinates, options: nil)
        }
    }

    func mapControlViewDidTapEaseTo(_ mapControlView: MapControlView) {
        Task {
            let brnoCoordinates: CLLocationCoordinate2D = Constants.brnoCoordinates
            let options = MTCameraOptions(zoom: Constants.defaultZoomLevel)

            await mapView.easeTo(brnoCoordinates, options: options)
        }
    }

    func mapControlView(_ mapControlView: MapControlView, didSelectBearing bearing: Double) {
        Task {
            await mapView.setBearing(bearing)
        }
    }
}

extension MainViewController: MapZoomControlViewDelegate {
    func mapZoomControlViewDidTapZoomIn(_ mapZoomControlView: MapZoomControlView) {
        Task {
            await mapView.zoomIn()
        }
    }

    func mapZoomControlViewDidTapZoomOut(_ mapZoomControlView: MapZoomControlView) {
        Task {
            await mapView.zoomOut()
        }
    }
}

extension MainViewController: MTMapViewDelegate {
    func mapViewDidInitialize(_ mapView: MTMapView) {
        print("-------------------------")
        print(">>> MapTiler SDK Demo <<<")
        print("--- Map Initialized ---")
        print("-------------------------")

        Task {
            await mapView.addMapTilerLogoControl(position: .topLeft)
        }

        // *** Uncomment for benchmark ***
//        Task {
//            benchmarkButton.isHidden = false
//            await MTConfig.shared.setLogLevel(.none)
//        }
        // *** ***
    }

    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?) {
        if event == .didLoad, mapView.isInitialized {
            loadingActivityIndicator.stopAnimating()
        }
    }
}
