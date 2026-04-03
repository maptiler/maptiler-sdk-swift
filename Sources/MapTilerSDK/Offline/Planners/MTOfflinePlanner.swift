//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflinePlanner.swift
//  MapTilerSDK
//

import Foundation

// Protocol defining the core interface for planning an offline download.
internal protocol MTOfflinePlanner {
    // Estimates the size and resources required for an offline region.
    func estimate(for definition: MTOfflineRegionDefinition) async throws -> MTTileEstimate

    // Generates a manifest detailing all resources required for an offline region.
    func generateManifest(for definition: MTOfflineRegionDefinition) async throws -> MTManifest
}
