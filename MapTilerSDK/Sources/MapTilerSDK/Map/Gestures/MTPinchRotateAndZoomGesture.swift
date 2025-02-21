//
//  MTPinchGesture.swift
//  MapTilerSDK
//

/// Handles zoom and rotate by pinching with two fingers.
@MainActor
public struct MTPinchRotateAndZoomGesture: MTGesture {
    public var type: MTGestureType = .pinchRotateAndZoom

    private var bridge: MTBridge!

    private init() {}

    package init(bridge: MTBridge) {
        self.bridge = bridge
    }

    public func disable() async {
        await bridge.execute(PinchRotateAndZoomDisable())
    }

    public func enable() async {
        await bridge.execute(PinchRotateAndZoomEnable())
    }
}
