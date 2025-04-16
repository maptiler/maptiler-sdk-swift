//
//  MapProjectionControlView.swift
//  MapTilerMobileDemo
//

import UIKit

protocol MapProjectionControlViewDelegate: AnyObject {
    func mapProjectionControlViewDidTapEnableGlobe(_ mapProjectionControlView: MapProjectionControlView)
    func mapProjectionControlViewDidTapEnableTerrain(_ mapProjectionControlView: MapProjectionControlView)
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
        delegate?.mapProjectionControlViewDidTapEnableGlobe(self)
    }

    @IBAction func enableTerrainButtonTouchUpInside(_ sender: UIButton) {
        delegate?.mapProjectionControlViewDidTapEnableTerrain(self)
    }
}
