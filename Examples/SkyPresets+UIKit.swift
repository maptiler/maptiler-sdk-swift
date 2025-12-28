//
//  SkyPresets+UIKit.swift
//  MapTilerSDK
//

import UIKit
import CoreLocation
import MapTilerSDK

class SkyPresetsViewController: UIViewController {
    enum SkyPreset: Int { case clear = 0, sunset = 1, night = 2, foggy = 3 }

    private enum C {
        static let pacific = CLLocationCoordinate2D(latitude: -20.0, longitude: -140.0)
    }

    private var mapView: MTMapView!
    private let segmented = UISegmentedControl(items: ["Clear", "Sunset", "Night", "Foggy"])
    private let reloadButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }
        view.backgroundColor = .systemBackground
        setupMap()
        setupUI()
    }

    private func setupMap() {
        let options = MTMapOptions()
        mapView = MTMapView(frame: view.bounds, options: options, referenceStyle: .basic, styleVariant: .defaultVariant)
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
    }

    private func setupUI() {
        segmented.selectedSegmentIndex = SkyPreset.clear.rawValue
        segmented.addTarget(self, action: #selector(changePreset), for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false

        reloadButton.setTitle("Force Reload Style", for: .normal)
        reloadButton.addTarget(self, action: #selector(forceReloadStyle), for: .touchUpInside)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [segmented, reloadButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }

    @objc private func changePreset() {
        Task { await applyCurrentPreset() }
    }

    @objc private func forceReloadStyle() {
        Task { @MainActor in
            await mapView.style?.forceReloadStyle()
            await applyCurrentPreset()
        }
    }

    @MainActor
    private func configureCamera() async {
        try? await mapView.setMaxPitch(85)
        await mapView.setVerticalFieldOfView(degrees: 45)
        await mapView.enableTerrain(exaggerationFactor: 1.0)
        await mapView.setIsCenterClampedToGround(false)

        let camera = MTCameraOptions(center: C.pacific, zoom: 5.5, bearing: 0.0, pitch: 80.0)
        await mapView.easeTo(C.pacific, options: camera, animationOptions: nil)
    }

    @MainActor
    private func applyCurrentPreset() async {
        let selected = SkyPreset(rawValue: segmented.selectedSegmentIndex) ?? .clear
        let sky: MTSky
        switch selected {
        case .clear:
            sky = MTSky(
                skyColor: .color(UIColor(red: 0.60, green: 0.78, blue: 0.94, alpha: 1.0)),
                skyHorizonBlend: .number(0.35),
                horizonColor: .color(UIColor(red: 0.72, green: 0.85, blue: 0.96, alpha: 1.0)),
                horizonFogBlend: .number(0.0),
                fogColor: .color(UIColor(white: 0.92, alpha: 1.0)),
                fogGroundBlend: .number(0.0),
                atmosphereBlend: .number(0.20)
            )
        case .sunset:
            sky = MTSky(
                skyColor: .color(UIColor(red: 0.34, green: 0.19, blue: 0.45, alpha: 1.0)),
                skyHorizonBlend: .number(0.55),
                horizonColor: .color(UIColor(red: 1.00, green: 0.55, blue: 0.30, alpha: 1.0)),
                horizonFogBlend: .number(0.0),
                fogColor: .color(UIColor(white: 0.92, alpha: 1.0)),
                fogGroundBlend: .number(0.0),
                atmosphereBlend: .number(0.45)
            )
        case .night:
            sky = MTSky(
                skyColor: .color(UIColor(red: 0.02, green: 0.06, blue: 0.16, alpha: 1.0)),
                skyHorizonBlend: .number(0.25),
                horizonColor: .color(UIColor(red: 0.04, green: 0.10, blue: 0.22, alpha: 1.0)),
                horizonFogBlend: .number(0.0),
                fogColor: .color(UIColor(white: 0.90, alpha: 1.0)),
                fogGroundBlend: .number(0.0),
                atmosphereBlend: .number(0.15)
            )
        case .foggy:
            sky = MTSky(
                skyColor: .color(UIColor(red: 0.80, green: 0.83, blue: 0.85, alpha: 1.0)),
                skyHorizonBlend: .number(0.80),
                horizonColor: .color(UIColor(red: 0.88, green: 0.90, blue: 0.91, alpha: 1.0)),
                horizonFogBlend: .number(0.60),
                fogColor: .color(UIColor(white: 0.92, alpha: 1.0)),
                fogGroundBlend: .number(0.50),
                atmosphereBlend: .number(0.35)
            )
        }
        await mapView.setSky(sky, options: MTStyleSetterOptions(shouldValidate: false))
    }
}

extension SkyPresetsViewController: MTMapViewDelegate {
    func mapViewDidInitialize(_ mapView: MTMapView) {
        Task { @MainActor in
            await configureCamera()
            await applyCurrentPreset()
        }
    }
}
