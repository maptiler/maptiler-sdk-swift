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
public final class MTHeatmapLayerHelper: @unchecked Sendable {
    private let style: MTStyle

    public init(_ style: MTStyle) {
        self.style = style
    }

    /// Adds a heatmap layer based on the provided options.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addHeatmap(
        _ options: MTHeatmapLayerOptions,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        style.addHeatmapLayer(
            options,
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
        await style.addHeatmapLayer(options, colorRamp: colorRamp, in: mapView)
    }
}
