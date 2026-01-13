//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTVectorLayerHelper.swift
//  MapTilerSDK
//

import Foundation

/// Base protocol adopted by vector layer helpers to share defaults
/// and common option normalization logic.
public protocol MTVectorLayerHelper: AnyObject {
    var style: MTStyle { get }

    // Base defaults shared across vector helpers
    static var baseMinZoom: Double { get }
    static var baseMaxZoom: Double { get }
    static var baseOutline: Bool { get }
    static var baseOutlineColor: MTStringOrZoomStringValues { get }
    static var baseOutlineWidth: MTNumberOrZoomNumberValues { get }
    static var baseOutlineOpacity: MTNumberOrZoomNumberValues { get }
}

public extension MTVectorLayerHelper {
    // Shared default values
    static var baseMinZoom: Double { 0 }
    static var baseMaxZoom: Double { 22 }
    static var baseOutline: Bool { false }
    static var baseOutlineColor: MTStringOrZoomStringValues { .string("white") }
    static var baseOutlineWidth: MTNumberOrZoomNumberValues { .number(1) }
    static var baseOutlineOpacity: MTNumberOrZoomNumberValues { .number(1) }

    // Normalize common options for Heatmap helper
    func applyCommonDefaults(to options: MTHeatmapLayerOptions) -> MTHeatmapLayerOptions {
        var normalized = options
        if normalized.minzoom == nil { normalized.minzoom = Self.baseMinZoom }
        if normalized.maxzoom == nil { normalized.maxzoom = Self.baseMaxZoom }
        return normalized
    }

    // Normalize common options for Point helper (includes outline family)
    func applyCommonDefaults(to options: MTPointLayerOptions) -> MTPointLayerOptions {
        var normalized = options
        if normalized.minzoom == nil { normalized.minzoom = Self.baseMinZoom }
        if normalized.maxzoom == nil { normalized.maxzoom = Self.baseMaxZoom }

        if normalized.outline == nil { normalized.outline = Self.baseOutline }
        // Apply outline attributes only when outline is requested
        if normalized.outline ?? Self.baseOutline {
            if normalized.outlineColor == nil { normalized.outlineColor = Self.baseOutlineColor }
            if normalized.outlineWidth == nil { normalized.outlineWidth = Self.baseOutlineWidth }
            if normalized.outlineOpacity == nil { normalized.outlineOpacity = Self.baseOutlineOpacity }
        }
        return normalized
    }
}
