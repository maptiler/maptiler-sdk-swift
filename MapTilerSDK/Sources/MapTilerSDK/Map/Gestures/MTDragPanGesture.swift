//
//  MTDragPanGesture.swift
//  MapTilerSDK
//

/// Handles panning the map by dragging.
@MainActor
public struct MTDragPanGesture: MTGesture {
    public var type: MTGestureType = .dragPan

    public func disable() async {
        await MTBridge.shared.execute(DragPanDisable())
    }

    public func enable() async {
        await MTBridge.shared.execute(DragPanEnable())
    }
}
