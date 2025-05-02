//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPinchGesture.swift
//  MapTilerSDK
//

/// Handles zoom and rotate by pinching with two fingers.
@MainActor
public struct MTPinchRotateAndZoomGesture: MTGesture {
    /// Type of the gesture.
    public var type: MTGestureType = .pinchRotateAndZoom

    private var bridge: MTBridge!

    private init() {}

    package init(bridge: MTBridge) {
        self.bridge = bridge
    }

    /// Disables the gesture on the map.
    public func disable() async {
        do {
            try await _ = bridge.execute(PinchRotateAndZoomDisable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }

    /// Enables the gesture on the map.
    public func enable() async {
        do {
            try await _ = bridge.execute(PinchRotateAndZoomEnable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }
}
