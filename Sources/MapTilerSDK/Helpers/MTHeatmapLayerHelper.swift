//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTHeatmapLayerHelper.swift
//  MapTilerSDK
//

import Foundation

/// Helper for creating a heatmap visualization layer from data and styling options.
public final class MTHeatmapLayerHelper: MTVectorLayerHelper, @unchecked Sendable {
    private let baseStyle: MTStyle

    public var style: MTStyle { baseStyle }

    public init(_ style: MTStyle) {
        self.baseStyle = style
    }

    /// Adds a heatmap layer based on the provided options.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addHeatmap(
        _ options: MTHeatmapLayerOptions,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let normalized = applyCommonDefaults(to: options)
        style.addHeatmapLayer(
            normalized,
            in: mapView,
            completionHandler: completionHandler
        )
    }

    /// Adds a heatmap layer using a color ramp.
    public func addHeatmap(
        _ options: MTHeatmapLayerOptions,
        colorRamp: MTColorRamp?,
        in mapView: MTMapView
    ) async {
        let normalized = applyCommonDefaults(to: options)
        await style.addHeatmapLayer(normalized, colorRamp: colorRamp, in: mapView)
    }
}
