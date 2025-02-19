//
//  DoubleTapZoomInGesture.swift
//  MapTilerSDK
//

/// Handles zooming in the map with double tap.
@MainActor
public struct MTDoubleTapZoomInGesture: MTGesture {
    public var type: MTGestureType = .doubleTapZoomIn

    private var bridge: MTBridge!

    private init() {}

    package init(bridge: MTBridge) {
        self.bridge = bridge
    }

    public func disable() async {
        await bridge.execute(DoubleTapZoomDisable())
    }

    public func enable() async {
        await bridge.execute(DoubleTapZoomEnable())
    }
}
