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

    @IBOutlet private weak var mapView: MTMapView! {
        didSet {
            mapView.delegate = self
        }
    }

    @IBOutlet private weak var mapControlView: MapControlView! {
        didSet {
            mapControlView.delegate = self
        }
    }

    @IBOutlet private weak var mapZoomControlView: MapZoomControlView! {
        didSet {
            mapZoomControlView.delegate = self
        }
    }

    @IBOutlet private weak var mapProjectionControlView: MapProjectionControlView! {
        didSet {
            mapProjectionControlView.delegate = self
        }
    }

    @IBOutlet private weak var jumpContainerView: UIView!
    @IBOutlet private weak var benchmarkButton: UIButton!
    @IBOutlet private weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var layerViewLeadingConstraint: NSLayoutConstraint!

    @IBOutlet private weak var layerView: LayerView! {
        didSet {
            layerView.delegate = self
        }
    }

    private var dataModel = JumpDataModel()
    private var cancellables = Set<AnyCancellable>()

    private var globeEnabled = false
    private var terrainEnabled = false

    private var layerViewIsVisible = false

    var contoursLayer: MTLineLayer!
    var aerowayLayer: MTFillLayer!
    var placeLayer: MTSymbolLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpJumpView()
        setUpLoadingActivityIndicator()
        setUpLongPress()

        setUpLayers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        AppDelegate.AppUtility.lockOrientation(.all)
    }

    private func setUpLayers() {
        contoursLayer = MTLineLayer(identifier: "contourslayer", sourceIdentifier: "contourssource")
        contoursLayer.color = .brown
        contoursLayer.width = 1
        contoursLayer.sourceLayer = "contour_ft"

        aerowayLayer = MTFillLayer(identifier: "aerowaylayer", sourceIdentifier: "openmapsource")
        aerowayLayer.color = .lightGray
        aerowayLayer.sourceLayer = "aeroway"

        placeLayer = MTSymbolLayer(identifier: "placelayer", sourceIdentifier: "openmapsource")
        placeLayer.icon = UIImage(named: "maptiler-marker")
        placeLayer.sourceLayer = "place"
    }

    private func setUpLongPress() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.delaysTouchesBegan = true

        self.jumpContainerView.addGestureRecognizer(longPressRecognizer)
    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        benchmarkButton.isHidden = false
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
            .compactMap { $0 }
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

    private func addSources() {
        Task {
            if let mapTilerAPIKey = await MTConfig.shared.getAPIKey() {
                if let openMapURL = URL(
                    string: "https://api.maptiler.com/tiles/v3-openmaptiles/tiles.json?key=\(mapTilerAPIKey)"
                ) {
                    let aerowaySource = MTVectorTileSource(identifier: "openmapsource", url: openMapURL)
                    try await mapView.style?.addSource(aerowaySource)
                }

                if let contoursURL = URL(
                    string: "https://api.maptiler.com/tiles/contours-v2/tiles.json?key=\(mapTilerAPIKey)"
                ) {
                    let contoursSource = MTVectorTileSource(identifier: "contourssource", url: contoursURL)
                    try await mapView.style?.addSource(contoursSource)
                }
            }
        }
    }

    @IBAction func layersButtonTouchUpInside(_ sender: UIButton) {
        layerViewLeadingConstraint.constant = layerViewIsVisible ? -layerView.frame.width : 0
        layerViewIsVisible = !layerViewIsVisible

        UIView.animate(withDuration: 0.8) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

extension MainViewController: MapControlViewDelegate {
    func mapControlViewDidTapFlyTo(_ mapControlView: MapControlView) {
        Task {
            let unterageriCoordinates: CLLocationCoordinate2D = Constants.unterageriCoordinates

            await mapView.flyTo(unterageriCoordinates, options: nil, animationOptions: nil)
        }
    }

    func mapControlViewDidTapEaseTo(_ mapControlView: MapControlView) {
        Task {
            let brnoCoordinates: CLLocationCoordinate2D = Constants.brnoCoordinates
            let options = MTCameraOptions(zoom: Constants.defaultZoomLevel)

            await mapView.easeTo(brnoCoordinates, options: options, animationOptions: nil)
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

extension MainViewController: MapProjectionControlViewDelegate {
    func mapProjectionControlViewDidTapEnableGlobe(_ mapProjectionControlView: MapProjectionControlView) {
        Task {
            if globeEnabled {
                await mapView.enableMercatorProjection()
            } else {
                await mapView.enableGlobeProjection()
            }

            globeEnabled = !globeEnabled
        }
    }

    func mapProjectionControlViewDidTapEnableTerrain(_ mapProjectionControlView: MapProjectionControlView) {
        Task {
            if terrainEnabled {
                await mapView.disableTerrain()
            } else {
                await mapView.enableTerrain()
            }

            terrainEnabled = !terrainEnabled
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

        loadingActivityIndicator.stopAnimating()

// *** Uncomment for benchmark or use long press on jump view ***
//        Task {
//            benchmarkButton.isHidden = false
//            await MTConfig.shared.setLogLevel(.none)
//        }
// *** ***
    }

    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?) {
        if event == .isReady {
            addSources()
        }
    }

    func mapView(_ mapView: MTMapView, didUpdateLocation location: CLLocation) {
        print("Device Coordinates: \(location.coordinate.latitude) - \(location.coordinate.longitude)")
    }
}

extension MainViewController: LayerViewDelegate {
    func layerView(_ layerView: LayerView, didUpdateLayerState state: Bool, layer: LayerType) {
        switch layer {
        case .contours:
            updateLayer(contoursLayer, for: state)
        case .aeroway:
            updateLayer(aerowayLayer, for: state)
        case .place:
            updateLayer(placeLayer, for: state)
        }
    }

    private func updateLayer(_ layer: MTLayer, for state: Bool) {
        Task {
            if state {
                try await mapView.style?.addLayer(layer)
            } else {
                try await mapView.style?.removeLayer(layer)
            }
        }
    }
}
