//
//  MTDragPanGesture.swift
//  MapTilerSDK
//

/// Handles panning the map by dragging.
@MainActor
public struct MTDragPanGesture: MTGesture {
    public var type: MTGestureType = .dragPan

    private var bridge: MTBridge!

    private init() {}

    package init(bridge: MTBridge) {
        self.bridge = bridge
    }

    public func disable() async {
        await bridge.execute(DragPanDisable())
    }

    public func enable() async {
        await bridge.execute(DragPanEnable())
    }
}
