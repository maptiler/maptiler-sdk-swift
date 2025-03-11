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
        do {
            try await _ = bridge.execute(PinchRotateAndZoomDisable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }

    public func enable() async {
        do {
            try await _ = bridge.execute(PinchRotateAndZoomEnable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }
}
