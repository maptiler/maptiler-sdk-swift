//
//  MTGestureService.swift
//  MapTilerSDK
//

/// Service responsible for gesture handling and state.
@MainActor
public class MTGestureService {
    public private(set) var enabledGestures: [MTGestureType: MTGesture] = [:]

    private var bridge: MTBridge!

    private init() {}

    package init(bridge: MTBridge) {
        self.bridge = bridge

        enabledGestures[.doubleTapZoomIn] = MTGestureFactory.makeGesture(with: .doubleTapZoomIn, bridge: bridge)
        enabledGestures[.dragPan] = MTGestureFactory.makeGesture(with: .dragPan, bridge: bridge)
        enabledGestures[.twoFingersDragPitch] = MTGestureFactory.makeGesture(with: .twoFingersDragPitch, bridge: bridge)
        enabledGestures[.pinchRotateAndZoom] = MTGestureFactory.makeGesture(with: .pinchRotateAndZoom, bridge: bridge)
    }

    /// Registers the gesture with the provided type.
    /// - Parameters:
    ///   - type: type of gesture to enable.
    public func enableGesture(with type: MTGestureType) async {
        enabledGestures[type] = MTGestureFactory.makeGesture(with: type, bridge: bridge)

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
