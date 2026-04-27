//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineTileResource.swift
//  MapTilerSDK
//

import Foundation

/// A combined representation of an offline tile and its storage destination.
public struct MTOfflineTileResource: Equatable, Hashable, Comparable {
    /// The source ID this tile belongs to.
    public let sourceId: String

    /// The tile coordinate.
    public let tile: MTOfflineTile

    /// The relative storage path for this tile.
    public let storagePath: MTStoragePath

    /// Initializes a new tile resource.
    ///
    /// - Parameters:
    ///   - sourceId: The map source ID.
    ///   - tile: The tile coordinate.
    ///   - extensionName: The file extension for the stored tile.
    public init(sourceId: String, tile: MTOfflineTile, extensionName: String) {
        self.sourceId = sourceId
        self.tile = tile
        self.storagePath = MTStoragePath(path: "sources/\(sourceId)/\(tile.z)/\(tile.x)/\(tile.y).\(extensionName)")
    }

    public static func < (lhs: MTOfflineTileResource, rhs: MTOfflineTileResource) -> Bool {
        if lhs.sourceId != rhs.sourceId {
            return lhs.sourceId < rhs.sourceId
        }
        if lhs.tile.z != rhs.tile.z {
            return lhs.tile.z < rhs.tile.z
        }
        if lhs.tile.x != rhs.tile.x {
            return lhs.tile.x < rhs.tile.x
        }
        return lhs.tile.y < rhs.tile.y
    }
}
