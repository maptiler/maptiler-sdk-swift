//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTerrain.swift
//  MapTilerSDK
//

/// Represents the 3D terrain specification.
public struct MTTerrain: Sendable, Codable, Equatable {
    /// The ID of the raster-dem source to use for terrain.
    public var source: String
    /// The exaggeration factor of the terrain.
    public var exaggeration: Double?

    public init(source: String, exaggeration: Double? = nil) {
        self.source = source
        self.exaggeration = exaggeration
    }
}
