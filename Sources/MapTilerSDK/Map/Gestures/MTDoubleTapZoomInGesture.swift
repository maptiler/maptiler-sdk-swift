//
//  DoubleTapZoomInGesture.swift
//  MapTilerSDK
//

/// Handles zooming in the map with double tap.
@MainActor
public struct MTDoubleTapZoomInGesture: MTGesture {
    /// Type of the gesture.
    public var type: MTGestureType = .doubleTapZoomIn

    private var bridge: MTBridge!

    private init() {}

    package init(bridge: MTBridge) {
        self.bridge = bridge
    }

    /// Disables the gesture on the map.
    public func disable() async {
        do {
            try await _ = bridge.execute(DoubleTapZoomDisable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }

    // Enables the gesture on the map.
    public func enable() async {
        do {
            try await _ = bridge.execute(DoubleTapZoomEnable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }
}
