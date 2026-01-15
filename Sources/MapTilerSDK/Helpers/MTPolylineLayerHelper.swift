//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPolylineLayerHelper.swift
//  MapTilerSDK
//

import Foundation

/// Helper for creating a polyline (line) visualization layer from data and styling options.
public final class MTPolylineLayerHelper: MTVectorLayerHelper, @unchecked Sendable {
    private let baseStyle: MTStyle

    public var style: MTStyle { baseStyle }

    public init(_ style: MTStyle) {
        self.baseStyle = style
    }

    // Normalize common defaults for polyline options using shared vector defaults
    private func applyCommonDefaults(to options: MTPolylineLayerOptions) -> MTPolylineLayerOptions {
        var normalized = options
        if normalized.minzoom == nil { normalized.minzoom = Self.baseMinZoom }
        if normalized.maxzoom == nil { normalized.maxzoom = Self.baseMaxZoom }

        if normalized.outline == nil { normalized.outline = Self.baseOutline }
        if normalized.outline ?? Self.baseOutline {
            if normalized.outlineColor == nil { normalized.outlineColor = Self.baseOutlineColor }
            if normalized.outlineWidth == nil { normalized.outlineWidth = Self.baseOutlineWidth }
            if normalized.outlineOpacity == nil { normalized.outlineOpacity = Self.baseOutlineOpacity }
            if normalized.outlineBlur == nil { normalized.outlineBlur = .number(0) }
        }
        return normalized
    }

    /// Adds a polyline layer based on the provided options.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addPolyline(
        _ options: MTPolylineLayerOptions,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let normalized = applyCommonDefaults(to: options)
        style.addPolylineLayer(normalized, completionHandler: completionHandler)
    }

    /// Adds a polyline layer based on the provided options (async).
    public func addPolyline(_ options: MTPolylineLayerOptions) async {
        let normalized = applyCommonDefaults(to: options)
        await style.addPolylineLayer(normalized)
    }
}
