//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTileURLTemplate.swift
//  MapTilerSDK
//

import Foundation

/// A helper struct for validating and building tile URLs from string templates.
public struct MTTileURLTemplate {

    /// Checks if a given template string contains the required minimum tokens.
    ///
    /// - Parameter template: The URL template string.
    /// - Returns: `true` if it contains `{z}`, `{x}`, and either `{y}` or `{-y}`.
    public static func isValid(template: String) -> Bool {
        guard template.contains("{z}") && template.contains("{x}") else {
            return false
        }
        return template.contains("{y}") || template.contains("{-y}")
    }

    /// Builds a full tile URL from a template string for given coordinates and scheme.
    ///
    /// This method seamlessly handles the `{-y}` token which implies a TMS-style inverted Y-axis,
    /// even if the `scheme` passed is explicitly XYZ. If `{-y}` is present, it will invert the Y coordinate.
    ///
    /// - Parameters:
    ///   - template: The URL template string (e.g., `https://example.com/tiles/{z}/{x}/{y}.pbf`).
    ///   - z: The zoom level.
    ///   - x: The X coordinate.
    ///   - y: The Y coordinate.
    ///   - scheme: The coordinate scheme (`.xyz` or `.tms`).
    /// - Returns: A valid `URL` if the template is correctly formatted, `nil` otherwise.
    public static func buildURL(template: String, z: Int, x: Int, y: Int, scheme: MTOfflineTileScheme = .xyz) -> URL? {
        var finalY = y

        // If the template explicitly uses {-y}, we need to invert the Y coordinate
        // regardless of the provided scheme enum, as MapLibre/TileJSON specs define {-y} as flipped.
        // Or, if the scheme is TMS and it just uses {y}, we also flip.
        let needsFlip = template.contains("{-y}") || (scheme == .tms && template.contains("{y}"))

        if needsFlip {
            finalY = MTOfflineTileCalculator.flipYCoordinate(y: y, zoom: z)
        }

        var urlString = template
            .replacingOccurrences(of: "{z}", with: String(z))
            .replacingOccurrences(of: "{x}", with: String(x))
            .replacingOccurrences(of: "{y}", with: String(finalY))
            .replacingOccurrences(of: "{-y}", with: String(finalY))

        // Also support MapLibre's {ratio} if present, default to empty or @2x
        // For standard tiles, we strip it out.
        urlString = urlString.replacingOccurrences(of: "{ratio}", with: "")

        return URL(string: urlString)
    }
}
