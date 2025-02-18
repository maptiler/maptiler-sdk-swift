//
//  MapStyleViewController.swift
//  MapTilerMobileDemo
//

import UIKit
import SwiftUI
import MapTilerSDK

class MapStyleViewController: UIViewController {
    @IBOutlet weak var mapStyleViewContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigateToMapStyleView()
    }

    private func navigateToMapStyleView() {
        let view = MapStyleView()
        let hostingController = UIHostingController(rootView: view)

        addChild(hostingController)

        hostingController.view.backgroundColor = .clear
        hostingController.view.frame = mapStyleViewContainer.bounds
        mapStyleViewContainer.addSubview(hostingController.view)

        hostingController.didMove(toParent: self)
    }
}
