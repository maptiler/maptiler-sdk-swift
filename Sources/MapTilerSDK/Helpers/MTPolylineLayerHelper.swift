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
        completionHandler: ((Result<MTPolylineLayerResult, MTError>) -> Void)? = nil
    ) {
        let normalized = applyCommonDefaults(to: options)
        style.addPolylineLayer(normalized, completionHandler: completionHandler)
    }

    /// Adds a polyline layer based on the provided options (async).
    public func addPolyline(
        _ options: MTPolylineLayerOptions
    ) async throws -> MTPolylineLayerResult {
        let normalized = applyCommonDefaults(to: options)
        return try await style.addPolylineLayer(normalized)
    }

    /// Removes the layers and source created by the `addPolyline` helper
    public func removePolyline(
        result: MTPolylineLayerResult,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let layersToRemove = [result.polylineLayerId, result.polylineOutlineLayerId].compactMap { $0 }
        style.mapView.runCommand(
            RemoveHelperResult(layerIds: layersToRemove, sourceId: result.polylineSourceId),
            completion: completionHandler
        )
    }

    /// Removes the layers and source created by the `addPolyline` helper
    public func removePolyline(result: MTPolylineLayerResult) async throws {
        try await withCheckedThrowingContinuation { continuation in
            removePolyline(result: result) { res in
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
