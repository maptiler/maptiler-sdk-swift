//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineTile.swift
//  MapTilerSDK
//

import Foundation

/// Represents a discrete tile coordinate in a map grid at a specific zoom level.
public struct MTOfflineTile: Equatable, Hashable, CustomStringConvertible {
    /// The X coordinate of the tile.
    public let x: Int
    /// The Y coordinate of the tile.
    public let y: Int
    /// The zoom level of the tile.
    public let z: Int

    /// Initializes a new tile coordinate.
    ///
    /// - Parameters:
    ///   - x: The X coordinate.
    ///   - y: The Y coordinate.
    ///   - z: The zoom level.
    public init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    public var description: String {
        return "Tile(x: \(x), y: \(y), z: \(z))"
    }
}
