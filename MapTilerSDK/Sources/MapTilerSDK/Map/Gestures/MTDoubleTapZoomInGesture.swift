//
//  DoubleTapZoomInGesture.swift
//  MapTilerSDK
//

/// Handles zooming in the map with double tap.
@MainActor
public struct MTDoubleTapZoomInGesture: MTGesture {
    public var type: MTGestureType = .doubleTapZoomIn

    public func disable() async {
        await MTBridge.shared.execute(DoubleTapZoomDisable())
    }

    public func enable() async {
        await MTBridge.shared.execute(DoubleTapZoomEnable())
    }
}
