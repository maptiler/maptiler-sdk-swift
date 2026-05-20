//
//  OfflineViewController.swift
//  MapTilerMobileDemo
//

import UIKit
import SwiftUI

class OfflineViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let offlineView = OfflineBasicView()
        let hostingController = UIHostingController(rootView: offlineView)

        addChild(hostingController)

        hostingController.view.backgroundColor = UIColor.clear
        hostingController.view.frame = view.bounds
        view.addSubview(hostingController.view)

        hostingController.didMove(toParent: self)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
