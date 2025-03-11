//
//  MTMap+MTZoomable.swift
//  MapTilerSDK
//

import UIKit

extension MTMapView: MTZoomable {
    /// Increases the map's zoom level by 1.
    public func zoomIn() async {
        await runCommand(ZoomIn())
    }

    /// Decreases the map's zoom level by 1.
    public func zoomOut() async {
        await runCommand(ZoomOut())
    }

    /// Returns the map's current zoom level.
    public func getZoom() async -> Double {
        return await runCommandWithDoubleReturnValue(GetZoom())
    }

    /// Sets the map's zoom level.
    ///  - Parameters:
    ///   - zoom: The zoom level to set (0-20).
    public func setZoom(_ zoom: Double) async {
        await runCommand(SetZoom(zoom: zoom))
    }
}
