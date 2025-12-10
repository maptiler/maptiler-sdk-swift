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
public final class MTPointLayerHelper: @unchecked Sendable {
    private let style: MTStyle

    public init(_ style: MTStyle) {
        self.style = style
    }

    /// Adds a point layer based on the provided options.
    @MainActor @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addPoint(_ options: MTPointLayerOptions, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        style.addPointLayer(options, completionHandler: completionHandler)
    }

    /// Adds a point layer based on the provided options.
    public func addPoint(_ options: MTPointLayerOptions) async {
        await style.addPointLayer(options)
    }
}
