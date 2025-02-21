//
//  MTTwoFingersDragPitch.swift
//  MapTilerSDK
//

/// Handles changing the pitch by dragging with two fingers.
@MainActor
public struct MTTwoFingersDragPitchGesture: MTGesture {
    public var type: MTGestureType = .twoFingersDragPitch

    private var bridge: MTBridge!

    private init() {}

    package init(bridge: MTBridge) {
        self.bridge = bridge
    }

    public func disable() async {
        await bridge.execute(TwoFingersDragPitchDisable())
    }

    public func enable() async {
        await bridge.execute(TwoFingersDragPitchEnable())
    }
}
