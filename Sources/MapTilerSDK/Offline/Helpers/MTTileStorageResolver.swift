//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTileStorageResolver.swift
//  MapTilerSDK
//

import Foundation

// Provides pure functions for grouping and mapping tiles to relative storage paths.
internal enum MTTileStorageResolver {

    // Defines input source data for merging tiles.
    internal struct SourceInput: Equatable, Hashable {
        public let sourceId: String
        public let extensionName: String

        public init(sourceId: String, extensionName: String) {
            self.sourceId = sourceId
            self.extensionName = extensionName
        }
    }

    // Maps a collection of tiles to tile resources for a specific source and extension.
    // The resulting array is stably ordered.
    internal static func resolve(
        tiles: [MTOfflineTile],
        sourceId: String,
        extensionName: String
    ) -> [MTOfflineTileResource] {
        return tiles.map { MTOfflineTileResource(sourceId: sourceId, tile: $0, extensionName: extensionName) }
            .sorted()
    }

    // Merges and resolves tiles from multiple sources into a single, deterministically sorted collection.
    internal static func mergeAndResolve(sources: [SourceInput: [MTOfflineTile]]) -> [MTOfflineTileResource] {
        var allResources: [MTOfflineTileResource] = []
        for (sourceInput, tiles) in sources {
            let resolved = resolve(
                tiles: tiles,
                sourceId: sourceInput.sourceId,
                extensionName: sourceInput.extensionName
            )
            allResources.append(contentsOf: resolved)
        }
        return allResources.sorted()
    }
}
