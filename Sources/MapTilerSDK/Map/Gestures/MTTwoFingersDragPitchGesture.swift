//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTwoFingersDragPitch.swift
//  MapTilerSDK
//

/// Handles changing the pitch by dragging with two fingers.
@MainActor
public struct MTTwoFingersDragPitchGesture: MTGesture {
    /// Type of the gesture.
    public var type: MTGestureType = .twoFingersDragPitch

    private var bridge: MTBridge!

    private init() {}

    package init(bridge: MTBridge) {
        self.bridge = bridge
    }

    /// Disables the gesture on the map.
    public func disable() async {
        do {
            try await _ = bridge.execute(TwoFingersDragPitchDisable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }

    /// Enables the gesture on the map.
    public func enable() async {
        do {
            try await _ = bridge.execute(TwoFingersDragPitchEnable())
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }
}
