//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTSourceType.swift
//  MapTilerSDK
//

/// Types of sources.
///
/// Sources state which data the map should display.
public enum MTSourceType: String, Codable {
    /// Vector tile source.
    case vector

    /// Raster tile source.
    case raster

    /// Raster DEM source.
    case rasterDEM = "raster-dem"

    /// GeoJSON source.
    case geojson

    /// Image source.
    case image

    /// Video source.
    case video
}
