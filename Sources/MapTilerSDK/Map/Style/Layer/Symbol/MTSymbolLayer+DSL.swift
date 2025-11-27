//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTSymbolLayer+DSL.swift
//  MapTilerSDK
//

import UIKit

// DSL
extension MTSymbolLayer {
    /// Adds layer to map DSL style.
    ///
    /// Prefer ``MTStyle/addLayer(_:)`` on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let layer = MTSymbolLayer(
                identifier: self.identifier,
                sourceIdentifier: self.sourceIdentifier,
                maxZoom: self.maxZoom,
                minZoom: self.minZoom,
                sourceLayer: self.sourceLayer,
                icon: self.icon,
                visibility: self.visibility
            )

            try await mapView.style?.addLayer(layer)
        }
    }

    /// Modifier. Sets the ``maxZoom``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func maxZoom(_ value: Double) -> Self {
        self.maxZoom = value

        return self
    }

    /// Modifier. Sets the ``minZoom``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func minZoom(_ value: Double) -> Self {
        self.maxZoom = value

        return self
    }

    /// Modifier. Sets the ``sourceLayer``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func sourceLayer(_ value: String) -> Self {
        self.sourceLayer = value

        return self
    }

    /// Modifier. Sets the ``icon``.
    /// - Note: Not to be used outside of DSL.
    public func icon(_ value: UIImage) -> Self {
        self.icon = value

        return self
    }

    /// Sets the symbol text field (tokens allowed).
    /// - Parameter value: Text field string, e.g. "{point_count_abbreviated}".
    @discardableResult
    public func textField(_ value: String) -> Self {
        self.textField = value
        return self
    }

    /// Sets the symbol text size.
    /// - Parameter value: Text size in points.
    @discardableResult
    public func textSize(_ value: Double) -> Self {
        self.textSize = value
        return self
    }

    /// Sets whether text labels can overlap.
    /// - Parameter value: True to allow overlap.
    @discardableResult
    public func textAllowOverlap(_ value: Bool) -> Self {
        self.textAllowOverlap = value
        return self
    }

    /// Sets the text anchor position.
    /// - Parameter value: Anchor for text placement.
    @discardableResult
    public func textAnchor(_ value: MTTextAnchor) -> Self {
        self.textAnchor = value
        return self
    }

    /// Sets the preferred text fonts.
    /// - Parameter value: Ordered list of font family names.
    @discardableResult
    public func textFont(_ value: [String]) -> Self {
        self.textFont = value
        return self
    }

    /// Sets a constant text color for the symbol.
    /// - Parameter value: UIColor value.
    @discardableResult
    public func paintTextColor(_ value: UIColor) -> Self {
        self.textColor = value
        return self
    }

    /// Modifier. Sets the ``visibility``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func visibility(_ value: MTLayerVisibility) -> Self {
        self.visibility = value

        return self
    }

    /// Sets an inline filter expression for this layer.
    /// - Parameter value: Filter expression.
    @discardableResult
    public func withFilter(_ value: MTPropertyValue) -> Self {
        self.filterExpression = value
        return self
    }
}
