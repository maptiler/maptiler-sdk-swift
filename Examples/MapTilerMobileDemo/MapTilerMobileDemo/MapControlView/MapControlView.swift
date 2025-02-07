//
//  MapControlView.swift
//  MapTilerMobileDemo
//

import UIKit

protocol MapControlViewDelegate: AnyObject {
    func mapControlViewDidTapZoomIn(_ mapControlView: MapControlView)
    func mapControlViewDidTapZoomOut(_ mapControlView: MapControlView)
}

class MapControlView: BaseView {
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!

    weak var delegate: MapControlViewDelegate?

    @IBAction func zoomInButtonTouchUpInside(_ sender: UIButton) {
        delegate?.mapControlViewDidTapZoomIn(self)
    }

    @IBAction func zoomOutButtonTouchUpInside(_ sender: UIButton) {
        delegate?.mapControlViewDidTapZoomOut(self)
    }
}
