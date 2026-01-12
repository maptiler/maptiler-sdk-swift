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
    @MainActor @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addPoint(_ options: MTPointLayerOptions, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        let normalized = applyCommonDefaults(to: options)
        style.addPointLayer(normalized, completionHandler: completionHandler)
    }

    /// Adds a point layer based on the provided options.
    public func addPoint(_ options: MTPointLayerOptions) async {
        let normalized = applyCommonDefaults(to: options)
        await style.addPointLayer(normalized)
    }

    /// Adds a point layer using a ColorRamp for pointColor.
    public func addPoint(_ options: MTPointLayerOptions, colorRamp: MTColorRamp, in mapView: MTMapView) async {
        let normalized = applyCommonDefaults(to: options)
        await style.addPointLayer(normalized, colorRamp: colorRamp, in: mapView)
    }
}
