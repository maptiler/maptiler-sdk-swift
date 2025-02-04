//
//  MainViewController.swift
//  MapTilerMobileDemo
//

import UIKit
import MapTilerSDK

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            guard let _ = await MTConfig.shared.getAPIKey() else {
                return
            }
        }
    }
}
