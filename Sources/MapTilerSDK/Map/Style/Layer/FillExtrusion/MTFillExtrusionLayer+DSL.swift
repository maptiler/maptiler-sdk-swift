//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTFillExtrusionLayer+DSL.swift
//  MapTilerSDK
//

import UIKit

// DSL
extension MTFillExtrusionLayer {
    /// Adds layer to map DSL style.
    /// Prefer MTStyle.addLayer(_:) on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let layer = MTFillExtrusionLayer(
                identifier: self.identifier,
                sourceIdentifier: self.sourceIdentifier,
                maxZoom: self.maxZoom,
                minZoom: self.minZoom,
                sourceLayer: self.sourceLayer,
                base: self.base,
                color: self.color,
                height: self.height,
                opacity: self.opacity,
                pattern: self.pattern,
                translate: self.translate,
                translateAnchor: self.translateAnchor,
                verticalGradient: self.verticalGradient,
                visibility: self.visibility
            )
            try await mapView.style?.addLayer(layer)
        }
    }

    // MARK: - Modifiers (not to be used outside DSL)

    @discardableResult
    public func maxZoom(_ value: Double) -> Self {
        self.maxZoom = value
        return self
    }

    @discardableResult
    public func minZoom(_ value: Double) -> Self {
        self.minZoom = value
        return self
    }

    @discardableResult
    public func sourceLayer(_ value: String) -> Self {
        self.sourceLayer = value
        return self
    }

    @discardableResult
    public func base(_ value: MTStyleValue) -> Self {
        self.base = value
        return self
    }

    @discardableResult
    public func color(_ value: MTStyleValue) -> Self {
        self.color = value
        return self
    }

    @discardableResult
    public func height(_ value: MTStyleValue) -> Self {
        self.height = value
        return self
    }

    @discardableResult
    public func opacity(_ value: MTStyleValue) -> Self {
        self.opacity = value
        return self
    }

    @discardableResult
    public func pattern(_ value: String) -> Self {
        self.pattern = value
        return self
    }

    @discardableResult
    public func translate(_ value: [Double]) -> Self {
        self.translate = value
        return self
    }

    @discardableResult
    public func translateAnchor(_ value: MTFillExtrusionTranslateAnchor) -> Self {
        self.translateAnchor = value
        return self
    }

    @discardableResult
    public func verticalGradient(_ value: Bool) -> Self {
        self.verticalGradient = value
        return self
    }

    @discardableResult
    public func visibility(_ value: MTLayerVisibility) -> Self {
        self.visibility = value
        return self
    }

    /// Modifier. Sets the initial filter to apply upon add.
    @discardableResult
    public func withFilter(_ value: MTPropertyValue) -> Self {
        self.initialFilter = value
        return self
    }
}
