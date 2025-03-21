//
//  MapProjectionControlView.swift
//  MapTilerMobileDemo
//

import UIKit

protocol MapProjectionControlViewDelegate: AnyObject {
    func mapZoomControlViewDidTapEnableGlobe(_ mapZoomControlView: MapProjectionControlView)
    func mapZoomControlViewDidTapEnableTerrain(_ mapZoomControlView: MapProjectionControlView)
}

class MapProjectionControlView: BaseView {
    @IBOutlet weak var enableGlobeButton: UIButton!
    @IBOutlet weak var enableTerrainButton: UIButton!

    weak var delegate: MapProjectionControlViewDelegate?

    override func commonInit() {
        super.commonInit()

        enableGlobeButton.addShadow()
        enableTerrainButton.addShadow()
    }

    @IBAction func enableGlobeButtonTouchUpInside(_ sender: UIButton) {
        delegate?.mapZoomControlViewDidTapEnableGlobe(self)
    }

    @IBAction func enableTerrainButtonTouchUpInside(_ sender: UIButton) {
        delegate?.mapZoomControlViewDidTapEnableTerrain(self)
    }
}
