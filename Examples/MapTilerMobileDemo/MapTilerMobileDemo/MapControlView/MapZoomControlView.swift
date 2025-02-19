//
//  MapZoomControlView.swift
//  MapTilerMobileDemo
//

import UIKit

protocol MapZoomControlViewDelegate: AnyObject {
    func mapZoomControlViewDidTapZoomIn(_ mapZoomControlView: MapZoomControlView)
    func mapZoomControlViewDidTapZoomOut(_ mapZoomControlView: MapZoomControlView)
}

class MapZoomControlView: BaseView {
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!

    weak var delegate: MapZoomControlViewDelegate?

    override func commonInit() {
        super.commonInit()

        zoomInButton.addShadow()
        zoomOutButton.addShadow()
    }

    @IBAction func zoomInButtonTouchUpInside(_ sender: UIButton) {
        delegate?.mapZoomControlViewDidTapZoomIn(self)
    }

    @IBAction func zoomOutButtonTouchUpInside(_ sender: UIButton) {
        delegate?.mapZoomControlViewDidTapZoomOut(self)
    }
}
