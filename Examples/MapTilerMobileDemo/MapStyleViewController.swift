//
//  MapStyleViewController.swift
//  MapTilerMobileDemo
//

import UIKit
import SwiftUI
import MapTilerSDK

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
    }
}
