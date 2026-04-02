//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPackStats.swift
//  MapTilerSDK
//

import Foundation

/// Statistics about an offline map pack.
public struct MTPackStats {
    /// Expected total size in bytes.
    public let expectedSize: Int64
    /// Expected total number of resources (tiles, glyphs, sprites, style).
    public let resourceCount: Int
    /// Expected number of tiles per source.
    public let tilesPerSource: [String: Int]

    public init(expectedSize: Int64, resourceCount: Int, tilesPerSource: [String: Int] = [:]) {
        self.expectedSize = expectedSize
        self.resourceCount = resourceCount
        self.tilesPerSource = tilesPerSource
    }
}
