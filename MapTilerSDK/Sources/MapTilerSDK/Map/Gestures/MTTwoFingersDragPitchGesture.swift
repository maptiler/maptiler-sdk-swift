//
//  MTTwoFingersDragPitch.swift
//  MapTilerSDK
//

/// Handles changing the pitch by dragging with two fingers.
@MainActor
public struct MTTwoFingersDragPitchGesture: MTGesture {
    public var type: MTGestureType = .twoFingersDragPitch

    public func disable() async {
        await MTBridge.shared.execute(TwoFingersDragPitchDisable())
    }

    public func enable() async {
        await MTBridge.shared.execute(TwoFingersDragPitchEnable())
    }
}
