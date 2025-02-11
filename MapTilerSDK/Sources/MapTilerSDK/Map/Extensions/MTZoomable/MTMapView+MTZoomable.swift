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
}
