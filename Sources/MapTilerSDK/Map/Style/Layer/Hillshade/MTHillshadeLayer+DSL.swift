//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTHillshadeLayer+DSL.swift
//  MapTilerSDK
//

import UIKit

// DSL
extension MTHillshadeLayer {
    /// Adds layer to map DSL style.
    ///
    /// Prefer `MTStyle/addLayer(_:)` on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let layer = MTHillshadeLayer(
                identifier: self.identifier,
                sourceIdentifier: self.sourceIdentifier,
                maxZoom: self.maxZoom,
                minZoom: self.minZoom,
                sourceLayer: self.sourceLayer,
                accentColor: self.accentColor,
                exaggeration: self.exaggeration,
                highlightColor: self.highlightColor,
                illuminationAnchor: self.illuminationAnchor,
                illuminationDirection: self.illuminationDirection,
                shadowColor: self.shadowColor,
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
    public func accentColor(_ value: UIColor) -> Self {
        self.accentColor = value
        return self
    }

    @discardableResult
    public func exaggeration(_ value: Double) -> Self {
        self.exaggeration = value
        return self
    }

    @discardableResult
    public func highlightColor(_ value: UIColor) -> Self {
        self.highlightColor = value
        return self
    }

    @discardableResult
    public func illuminationAnchor(_ value: MTHillshadeIlluminationAnchor) -> Self {
        self.illuminationAnchor = value
        return self
    }

    @discardableResult
    public func illuminationDirection(_ value: Double) -> Self {
        self.illuminationDirection = value
        return self
    }

    @discardableResult
    public func shadowColor(_ value: UIColor) -> Self {
        self.shadowColor = value
        return self
    }

    @discardableResult
    public func visibility(_ value: MTLayerVisibility) -> Self {
        self.visibility = value
        return self
    }
}
