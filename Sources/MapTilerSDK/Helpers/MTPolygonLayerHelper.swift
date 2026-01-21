//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPolygonLayerHelper.swift
//  MapTilerSDK
//

import Foundation

/// Helper for creating a polygon (fill) visualization layer from data and styling options.
public final class MTPolygonLayerHelper: MTVectorLayerHelper, @unchecked Sendable {
    private let baseStyle: MTStyle

    public var style: MTStyle { baseStyle }

    public init(_ style: MTStyle) {
        self.baseStyle = style
    }

    // Normalize common defaults for polygon options using shared vector defaults
    private func applyCommonDefaults(to options: MTPolygonLayerOptions) -> MTPolygonLayerOptions {
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

    /// Adds a polygon layer based on the provided options.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addPolygon(
        _ options: MTPolygonLayerOptions,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let normalized = applyCommonDefaults(to: options)
        style.addPolygonLayer(normalized, completionHandler: completionHandler)
    }

    /// Adds a polygon layer based on the provided options (async).
    public func addPolygon(_ options: MTPolygonLayerOptions) async {
        let normalized = applyCommonDefaults(to: options)
        await style.addPolygonLayer(normalized)
    }
}
