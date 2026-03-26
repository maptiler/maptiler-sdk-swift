//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointLayerHelper.swift
//  MapTilerSDK
//

import Foundation

/// Helper for creating a point visualization layer from data and styling options.
///
/// Uses the current style to create the underlying source and layers.
public final class MTPointLayerHelper: MTVectorLayerHelper, @unchecked Sendable {
    private let baseStyle: MTStyle

    public var style: MTStyle { baseStyle }

    public init(_ style: MTStyle) {
        self.baseStyle = style
    }

    /// Adds a point layer based on the provided options.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addPoint(
        _ options: MTPointLayerOptions,
        completionHandler: ((Result<MTPointLayerResult, MTError>) -> Void)? = nil
    ) {
        let normalized = applyCommonDefaults(to: options)
        style.addPointLayer(normalized, completionHandler: completionHandler)
    }

    /// Adds a point layer based on the provided options.
    @MainActor
    public func addPoint(
        _ options: MTPointLayerOptions
    ) async throws -> MTPointLayerResult {
        let normalized = applyCommonDefaults(to: options)
        return try await style.addPointLayer(normalized)
    }

    /// Adds a point layer using a ColorRamp for pointColor.
    public func addPoint(
        _ options: MTPointLayerOptions,
        colorRamp: MTColorRamp,
        in mapView: MTMapView
    ) async throws -> MTPointLayerResult {
        let normalized = applyCommonDefaults(to: options)
        return try await style.addPointLayer(normalized, colorRamp: colorRamp, in: mapView)
    }

    /// Adds a point layer using a ColorRamp for pointColor (completion-based variant).
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addPoint(
        _ options: MTPointLayerOptions,
        colorRamp: MTColorRamp,
        in mapView: MTMapView,
        completionHandler: ((Result<MTPointLayerResult, MTError>) -> Void)? = nil
    ) {
        let normalized = applyCommonDefaults(to: options)
        style.addPointLayer(normalized, colorRamp: colorRamp, in: mapView, completionHandler: completionHandler)
    }

    /// Removes the layers and source created by the `addPoint` helper
    @MainActor
    public func removePoint(
        result: MTPointLayerResult,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let layersToRemove = [result.pointLayerId, result.clusterLayerId, result.labelLayerId].compactMap { $0 }
        style.mapView.runCommand(
            RemoveHelperResult(layerIds: layersToRemove, sourceId: result.pointSourceId),
            completion: completionHandler
        )
    }

    /// Removes the layers and source created by the `addPoint` helper
    @MainActor
    public func removePoint(result: MTPointLayerResult) async throws {
        try await withCheckedThrowingContinuation { continuation in
            removePoint(result: result) { res in
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
