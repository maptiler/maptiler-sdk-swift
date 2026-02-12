//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTBackgroundLayer+DSL.swift
//  MapTilerSDK
//

import UIKit

// DSL
extension MTBackgroundLayer {
    /// Adds layer to map DSL style.
    ///
    /// Prefer `MTStyle.addLayer(_:)` on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let layer = MTBackgroundLayer(
                identifier: self.identifier,
                maxZoom: self.maxZoom,
                minZoom: self.minZoom,
                color: self.color,
                opacity: self.opacity,
                pattern: self.pattern,
                visibility: self.visibility
            )

            try await mapView.style?.addLayer(layer)
        }
    }

    // MARK: - Modifiers (for DSL chaining). Not for external use.
    @discardableResult public func maxZoom(_ value: Double) -> Self { self.maxZoom = value; return self }
    @discardableResult public func minZoom(_ value: Double) -> Self { self.minZoom = value; return self }

    /// Sets a constant background color value.
    @discardableResult public func color(_ value: UIColor) -> Self { self.color = .color(value); return self }

    /// Sets a background color expression (e.g., interpolate by zoom).
    @discardableResult public func paintColorExpression(_ expr: MTPropertyValue) -> Self {
        self.color = .expression(expr)
        return self
    }

    /// Sets the background opacity (0–1).
    @discardableResult public func opacity(_ value: Double) -> Self { self.opacity = value; return self }

    /// Sets the background sprite pattern name.
    @discardableResult public func pattern(_ value: String) -> Self { self.pattern = value; return self }

    /// Sets the background visibility.
    @discardableResult public func visibility(_ value: MTLayerVisibility) -> Self {
        self.visibility = value
        return self
    }
}
