//
//  MTGestureService.swift
//  MapTilerSDK
//

/// Service responsible for gesture handling and state.
@MainActor
public class MTGestureService {
    public private(set) var enabledGestures: [MTGestureType: MTGesture] = [:]

    private var bridge: MTBridge!
    private var eventProcessor: EventProcessor!

    private init() {}

    package init(bridge: MTBridge, eventProcessor: EventProcessor) {
        self.bridge = bridge
        self.eventProcessor = eventProcessor

        enabledGestures[.doubleTapZoomIn] = MTGestureFactory.makeGesture(with: .doubleTapZoomIn, bridge: bridge)
        enabledGestures[.dragPan] = MTGestureFactory.makeGesture(with: .dragPan, bridge: bridge)
        enabledGestures[.twoFingersDragPitch] = MTGestureFactory.makeGesture(with: .twoFingersDragPitch, bridge: bridge)
        enabledGestures[.pinchRotateAndZoom] = MTGestureFactory.makeGesture(with: .pinchRotateAndZoom, bridge: bridge)
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

    /// Enables drag to pan gesture.
    /// - Parameters:
    ///   - options: Drag to pan options (optional).
    public func enableDragPanGesture(options: MTDragPanOptions? = nil) async {
        enabledGestures[.dragPan] = MTGestureFactory.makeGesture(with: .dragPan, bridge: bridge)

        guard let dragPanGesture = enabledGestures[.dragPan] as? MTDragPanGesture else {
            return
        }

        if let options {
            await dragPanGesture.enable(with: options)
        } else {
            await dragPanGesture.enable()
        }
    }

    /// Enables pinch to rotate and zoom gesture.
    public func enablePinchRotateAndZoomGesture() async {
        enabledGestures[.pinchRotateAndZoom] = MTGestureFactory.makeGesture(with: .pinchRotateAndZoom, bridge: bridge)

        let pinchRotateAndZoomGesture = enabledGestures[.pinchRotateAndZoom] as? MTPinchRotateAndZoomGesture
        guard let pinchRotateAndZoomGesture else {
            return
        }

        await pinchRotateAndZoomGesture.enable()
    }

    /// Enables two fingers drag pitch gesture.
    public func enableTwoFingerDragPitchGesture() async {
        enabledGestures[.twoFingersDragPitch] = MTGestureFactory.makeGesture(with: .twoFingersDragPitch, bridge: bridge)

        let twoFingersDragPitchGesture = enabledGestures[.twoFingersDragPitch] as? MTTwoFingersDragPitchGesture
        guard let twoFingersDragPitchGesture else {
            return
        }

        await twoFingersDragPitchGesture.enable()
    }

    /// Enables double tap zoom in gesture.
    public func enableDoubleTapZoomInGesture() async {
        enabledGestures[.doubleTapZoomIn] = MTGestureFactory.makeGesture(with: .doubleTapZoomIn, bridge: bridge)

        let doubleTapZoomInGesture = enabledGestures[.doubleTapZoomIn] as? MTDoubleTapZoomInGesture
        guard let doubleTapZoomInGesture else {
            return
        }

        await doubleTapZoomInGesture.enable()
    }

    /// Sets the double tap sensitivity level (i.e. required time between taps).
    /// - Note: Default: 0.4
    public func setDoubleTapSensitivity(_ sensitivity: Double) {
        eventProcessor.setDoubleTapSensitivity(sensitivity)
    }
}
