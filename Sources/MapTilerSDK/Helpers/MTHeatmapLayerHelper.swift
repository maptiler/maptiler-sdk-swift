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
        completionHandler: ((Result<MTHeatmapLayerResult, MTError>) -> Void)? = nil
    ) {
        let normalized = applyCommonDefaults(to: options)
        style.addHeatmapLayer(normalized, in: style.mapView, completionHandler: completionHandler)
    }

    /// Adds a heatmap layer based on the provided options (async).
    @MainActor
    public func addHeatmap(
        _ options: MTHeatmapLayerOptions
    ) async throws -> MTHeatmapLayerResult {
        let normalized = applyCommonDefaults(to: options)
        return try await style.addHeatmapLayer(normalized, in: style.mapView)
    }

    /// Adds a heatmap layer using a ColorRamp for styling (async).
    @MainActor
    public func addHeatmap(
        _ options: MTHeatmapLayerOptions,
        colorRamp: MTColorRamp? = nil,
        in mapView: MTMapView
    ) async throws -> MTHeatmapLayerResult {
        let normalized = applyCommonDefaults(to: options)
        return try await style.addHeatmapLayer(normalized, colorRamp: colorRamp, in: mapView)
    }

    /// Removes the layers and source created by the `addHeatmap` helper
    @MainActor
    public func removeHeatmap(
        result: MTHeatmapLayerResult,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let layersToRemove = [result.heatmapLayerId].compactMap { $0 }
        style.mapView.runCommand(
            RemoveHelperResult(layerIds: layersToRemove, sourceId: result.heatmapSourceId),
            completion: completionHandler
        )
    }

    /// Removes the layers and source created by the `addHeatmap` helper
    @MainActor
    public func removeHeatmap(result: MTHeatmapLayerResult) async throws {
        try await withCheckedThrowingContinuation { continuation in
            removeHeatmap(result: result) { res in
                switch res {
                case .success:
                    continuation.resume()
                case .failure(let err):
                    continuation.resume(throwing: err)
                }
            }
        }
    }
}
