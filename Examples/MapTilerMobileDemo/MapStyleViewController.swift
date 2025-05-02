//
//  MapStyleViewController.swift
//  MapTilerMobileDemo
//

import UIKit
import SwiftUI
import MapTilerSDK
import CoreLocation

class MapStyleViewController: UIViewController {
    @IBOutlet weak var mapStyleViewContainer: UIView!

    private var mapView: MapStyleView?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigateToMapStyleView()
    }

    private func navigateToMapStyleView() {
        mapView = MapStyleView()
        let hostingController = UIHostingController(rootView: mapView)

        addChild(hostingController)

        hostingController.view.backgroundColor = .clear
        hostingController.view.frame = mapStyleViewContainer.bounds
        mapStyleViewContainer.addSubview(hostingController.view)

        hostingController.didMove(toParent: self)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: mapStyleViewContainer.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: mapStyleViewContainer.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: mapStyleViewContainer.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: mapStyleViewContainer.bottomAnchor),
        ])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PreviewSegue", let vc = segue.destination as? PreviewVC, let map = mapView {
            vc.mapView = MTMapView(
                frame: map.mapView.frame,
                options: map.mapView.options ?? MTMapOptions(),
                referenceStyle: map.mapView.style?.referenceStyle ?? .streets,
                styleVariant: map.mapView.style?.styleVariant
            )
        }
    }
}
