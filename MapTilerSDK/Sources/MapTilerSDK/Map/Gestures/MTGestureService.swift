//
//  MTGestureService.swift
//  MapTilerSDK
//

/// Service responsible for gesture handling and state.
@MainActor
public class MTGestureService {
    public private(set) var enabledGestures: [MTGestureType: MTGesture] = [:]

    init() {
        enabledGestures[.doubleTapZoomIn] = MTDoubleTapZoomInGesture()
    }

    /// Registers the gesture with the provided type.
    /// - Parameters:
    ///   - type: type of gesture to enable.
    public func enableGesture(with type: MTGestureType) async {
        enabledGestures[type] = MTDoubleTapZoomInGesture()

        await enabledGestures[type]!.enable()
    }

    /// Removes the gesture with the provided type from the map.
    /// - Parameters:
    ///   - type: type of gesture to disable.
    public func disableGesture(with type: MTGestureType) async {
        if let gesture = enabledGestures[type] {
            await gesture.disable()

            enabledGestures.removeValue(forKey: type)
        }
    }
}
