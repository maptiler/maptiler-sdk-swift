//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTCircleLayer+DSL.swift
//  MapTilerSDK
//

import UIKit

// DSL
extension MTCircleLayer {
    /// Adds layer to map DSL style.
    ///
    /// Prefer ``MTStyle/addLayer(_:)`` on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let layer = MTCircleLayer(
                identifier: self.identifier,
                sourceIdentifier: self.sourceIdentifier,
                maxZoom: self.maxZoom,
                minZoom: self.minZoom,
                sourceLayer: self.sourceLayer,
                blur: self.blur,
                color: self.color,
                opacity: self.opacity,
                radius: self.radius,
                strokeColor: self.strokeColor,
                strokeOpacity: self.strokeOpacity,
                strokeWidth: self.strokeWidth,
                translate: self.translate,
                translateAnchor: self.translateAnchor,
                sortKey: self.sortKey,
                visibility: self.visibility
            )
            layer.pitchAlignment = self.pitchAlignment
            layer.pitchScale = self.pitchScale

            try await mapView.style?.addLayer(layer)
        }
    }

    // MARK: - Modifiers (for DSL chaining). Not for external use.
    @discardableResult public func maxZoom(_ value: Double) -> Self { self.maxZoom = value; return self }
    @discardableResult public func minZoom(_ value: Double) -> Self { self.minZoom = value; return self }
    @discardableResult public func sourceLayer(_ value: String) -> Self { self.sourceLayer = value; return self }
    @discardableResult public func blur(_ value: Double) -> Self { self.blur = value; return self }
    @discardableResult public func color(_ value: UIColor) -> Self { self.color = .color(value); return self }
    @discardableResult public func opacity(_ value: Double) -> Self { self.opacity = value; return self }
    @discardableResult public func radius(_ value: Double) -> Self { self.radius = .number(value); return self }
    @discardableResult public func strokeColor(_ value: UIColor) -> Self { self.strokeColor = value; return self }
    @discardableResult public func strokeOpacity(_ value: Double) -> Self { self.strokeOpacity = value; return self }
    @discardableResult public func strokeWidth(_ value: Double) -> Self { self.strokeWidth = value; return self }
    @discardableResult public func translate(_ value: [Double]) -> Self { self.translate = value; return self }
    @discardableResult
    public func translateAnchor(_ value: MTCircleTranslateAnchor) -> Self {
        self.translateAnchor = value
        return self
    }
    /// Sets the sort key for feature ordering.
    /// - Parameter value: Sort key; higher draws above lower.
    @discardableResult public func sortKey(_ value: Double) -> Self { self.sortKey = value; return self }
    @discardableResult
    public func visibility(_ value: MTLayerVisibility) -> Self {
        self.visibility = value
        return self
    }

    @discardableResult
    /// Sets the pitch alignment for the circle.
    /// - Parameter value: Pitch alignment.
    public func pitchAlignment(_ value: MTCirclePitchAlignment) -> Self {
        self.pitchAlignment = value
        return self
    }

    @discardableResult
    /// Sets the pitch scaling behavior for the circle.
    /// - Parameter value: Pitch scale.
    public func pitchScale(_ value: MTCirclePitchScale) -> Self {
        self.pitchScale = value
        return self
    }

    @discardableResult
    /// Sets the inline filter expression for this layer.
    /// - Parameter value: Filter expression.
    public func withFilter(_ value: MTPropertyValue) -> Self {
        self.filterExpression = value
        return self
    }

    /// Sets a circle color expression (e.g., step).
    /// - Parameter expr: Expression to drive circle color.
    @discardableResult public func paintColorExpression(_ expr: MTPropertyValue) -> Self {
        self.color = .expression(expr)
        return self
    }

    /// Sets a circle radius expression (e.g., step).
    /// - Parameter expr: Expression to drive circle radius.
    @discardableResult public func paintRadiusExpression(_ expr: MTPropertyValue) -> Self {
        self.radius = .expression(expr)
        return self
    }

    /// Sets a constant circle color value.
    /// - Parameter color: UIColor value.
    @discardableResult public func paintColor(_ color: UIColor) -> Self {
        self.color = .color(color)
        return self
    }

    /// Sets a constant circle radius value in pixels.
    /// - Parameter value: Radius in pixels.
    @discardableResult public func paintRadius(_ value: Double) -> Self {
        self.radius = .number(value)
        return self
    }
}
