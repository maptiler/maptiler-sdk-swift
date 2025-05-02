//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTDragPanGesture.swift
//  MapTilerSDK
//

/// Handles panning the map by dragging.
@MainActor
public struct MTDragPanGesture: MTGesture {
    /// Type of the gesture.
    public var type: MTGestureType = .dragPan

    private var bridge: MTBridge!

    private init() {}

    package init(bridge: MTBridge) {
        self.bridge = bridge
    }

    /// Disables the gesture on the map.
    public func disable() async {
        do {
            try await _ = bridge.execute(DragPanDisable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }

    /// Enables the gesture on the map.
    public func enable() async {
        do {
            try await _ = bridge.execute(DragPanEnable(options: nil))
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }

    /// Enables the gesture on the map with options.
    ///  - Parameters:
    ///     - options: Drag and pan options.
    public func enable(with options: MTDragPanOptions) async {
        do {
            try await _ = bridge.execute(DragPanEnable(options: options))
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }
}
