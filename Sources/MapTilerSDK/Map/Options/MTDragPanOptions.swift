//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTDragPanOptions.swift
//  MapTilerSDK
//

/// Options for drag and pan gesstures.
public struct MTDragPanOptions: Sendable, Codable {
    /// Factor used to scale the drag velocity.
    /// - Note: Default: 0
    public var linearity: Double?

    /// The maximum value of the drag velocity.
    /// - Note: Default: 1400
    public var maxSpeed: Double?

    /// The rate at which the speed reduces after the pan ends.
    /// - Note: Default: 2500
    public var deceleration: Double?

    /// Initializes the options with linearity, maxSpeed and deceleration.
    public init(linearity: Double? = nil, maxSpeed: Double? = nil, deceleration: Double? = nil) {
        self.linearity = linearity
        self.maxSpeed = maxSpeed
        self.deceleration = deceleration
    }
}
