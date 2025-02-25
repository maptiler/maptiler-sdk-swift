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
        do {
            try await bridge.execute(TwoFingersDragPitchDisable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }

    public func enable() async {
        do {
            try await bridge.execute(TwoFingersDragPitchEnable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }
}
