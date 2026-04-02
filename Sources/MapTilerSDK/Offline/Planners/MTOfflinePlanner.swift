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
    // Generates a manifest detailing all resources required for an offline region.
    func generateManifest(
        styleURL: URL,
        bbox: MTBoundingBox,
        minZoom: Int,
        maxZoom: Int,
        pixelRatio: Float
    ) async throws -> MTManifest

    // Generates a manifest detailing all resources required for an offline region.
    func generateManifest(
        mapId: String,
        bbox: MTBoundingBox,
        minZoom: Int,
        maxZoom: Int,
        pixelRatio: Float
    ) async throws -> MTManifest
}
