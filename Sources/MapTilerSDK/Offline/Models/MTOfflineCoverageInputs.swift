//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineCoverageInputs.swift
//  MapTilerSDK
//

import Foundation

/// Defines the tile coordinate scheme used by the tile source.
public enum MTOfflineTileScheme: String, Equatable {
    /// Slippy Map (standard Web Mercator) scheme, where Y=0 is at the top.
    case xyz
    /// OSGeo Tile Map Service scheme, where Y=0 is at the bottom.
    case tms
}

/// Defines a standardized size for tiles.
public enum MTOfflineTileSize: Int, Equatable {
    case size256 = 256
    case size512 = 512

    /// Initializes a tile size, ensuring only valid sizes are created.
    public init(validating size: Int) throws {
        switch size {
        case 256:
            self = .size256
        case 512:
            self = .size512
        default:
            throw MTOfflineCoverageInputError.invalidTileSize("Tile size must be 256 or 512, received \(size)")
        }
    }
}

/// Defines and validates a zoom range for offline tile calculations.
public struct MTOfflineZoomRange: Equatable {
    public let minZoom: Int
    public let maxZoom: Int

    /// Initializes a zoom range.
    ///
    /// - Parameters:
    ///   - minZoom: The minimum zoom level. Must be >= 0.
    ///   - maxZoom: The maximum zoom level. Must be >= 0 and >= minZoom.
    /// - Throws: `MTOfflineCoverageInputError` if zoom levels are negative or if minZoom > maxZoom.
    ///   Note: Zoom levels greater than 22 are clamped to 22.
    public init(minZoom: Int, maxZoom: Int) throws {
        guard minZoom >= 0 else {
            throw MTOfflineCoverageInputError.invalidZoom("minZoom cannot be negative")
        }
        guard maxZoom >= 0 else {
            throw MTOfflineCoverageInputError.invalidZoom("maxZoom cannot be negative")
        }
        guard minZoom <= maxZoom else {
            throw MTOfflineCoverageInputError.invalidZoomRange(
                "minZoom (\(minZoom)) cannot be greater than maxZoom (\(maxZoom))"
            )
        }

        self.minZoom = Swift.min(minZoom, 22)
        self.maxZoom = Swift.min(maxZoom, 22)
    }
}

/// Errors that can occur during coverage input normalization.
public enum MTOfflineCoverageInputError: Error, Equatable {
    case invalidZoom(String)
    case invalidZoomRange(String)
    case invalidTileSize(String)
    case invalidScheme(String)
}

/// Holds normalized and validated coverage input parameters required for calculating tile coverage.
public struct MTOfflineCoverageInputs: Equatable {
    /// The tile scheme (xyz or tms).
    public let scheme: MTOfflineTileScheme
    /// The validated zoom range for the download.
    public let zoomRange: MTOfflineZoomRange
    /// The standardized tile size (e.g., 256 or 512).
    public let tileSize: MTOfflineTileSize

    /// Initializes and normalizes raw inputs into coverage inputs.
    ///
    /// - Parameters:
    ///   - scheme: The scheme string from a source/TileJSON. Defaults to "xyz" if nil.
    ///   - minZoom: The minimum zoom level requested.
    ///   - maxZoom: The maximum zoom level requested.
    ///   - tileSize: The tile size in pixels (e.g., 256 or 512). Defaults to 512.
    /// - Throws: `MTOfflineCoverageInputError` if validation fails.
    public init(scheme: String? = nil, minZoom: Int, maxZoom: Int, tileSize: Int = 512) throws {
        if let schemeStr = scheme {
            let lowercased = schemeStr.lowercased()
            if lowercased == "tms" {
                self.scheme = .tms
            } else if lowercased == "xyz" {
                self.scheme = .xyz
            } else {
                throw MTOfflineCoverageInputError.invalidScheme("Invalid scheme string: \(schemeStr)")
            }
        } else {
            self.scheme = .xyz
        }

        self.zoomRange = try MTOfflineZoomRange(minZoom: minZoom, maxZoom: maxZoom)
        self.tileSize = try MTOfflineTileSize(validating: tileSize)
    }
}
