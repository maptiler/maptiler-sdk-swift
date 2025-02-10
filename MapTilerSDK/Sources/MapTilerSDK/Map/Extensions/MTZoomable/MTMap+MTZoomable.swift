//
//  MTMap+MTZoomable.swift
//  MapTilerSDK
//

import UIKit

extension MTMapView: MTZoomable {
    /// Increases the map's zoom level by 1.
    public func zoomIn() async {
        await MTBridge.shared.execute(ZoomIn())
    }

    /// Decreases the map's zoom level by 1.
    public func zoomOut() async {
        await MTBridge.shared.execute(ZoomOut())
    }

    package func setUpDoubleTapGestureRecognizer() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGestureRecognizer)
    }

    @objc package func doubleTapped() async {
        await zoomIn()
    }
}
