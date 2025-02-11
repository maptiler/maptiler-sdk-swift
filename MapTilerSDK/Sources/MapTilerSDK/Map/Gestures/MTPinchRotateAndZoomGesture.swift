//
//  MTPinchGesture.swift
//  MapTilerSDK
//

/// Handles zoom and rotate by pinching with two fingers.
@MainActor
public struct MTPinchRotateAndZoomGesture: MTGesture {
    public var type: MTGestureType = .pinchRotateAndZoom

    public func disable() async {
        await MTBridge.shared.execute(PinchRotateAndZoomDisable())
    }

    public func enable() async {
        await MTBridge.shared.execute(PinchRotateAndZoomEnable())
    }
}
