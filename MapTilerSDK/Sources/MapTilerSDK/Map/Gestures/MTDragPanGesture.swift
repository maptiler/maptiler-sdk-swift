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
        do {
            try await bridge.execute(DragPanDisable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }

    public func enable() async {
        do {
            try await bridge.execute(DragPanEnable(options: nil))
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }

    public func enable(with options: MTDragPanOptions) async {
        do {
            try await bridge.execute(DragPanEnable(options: options))
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }
}
