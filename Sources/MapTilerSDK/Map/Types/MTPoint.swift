//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPoint.swift
//  MapTilerSDK
//

/// Two numbers representing x and y screen coordinates in pixels.
public struct MTPoint: Codable, Sendable {
    /// X value
    public var x: Double

    /// Y value.
    public var y: Double

    /// Initializes the point with x and y values.
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
