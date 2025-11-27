//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTFillLayer+DSL.swift
//  MapTilerSDK
//

import UIKit

// DSL
extension MTFillLayer {
    /// Adds layer to map DSL style.
    ///
    /// Prefer ``MTStyle/addLayer(_:)`` on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let layer = MTFillLayer(
                identifier: self.identifier,
                sourceIdentifier: self.sourceIdentifier,
                maxZoom: self.maxZoom,
                minZoom: self.minZoom,
                sourceLayer: self.sourceLayer,
                shouldBeAntialised: self.shouldBeAntialised,
                color: self.color,
                opacity: self.opacity,
                outlineColor: self.outlineColor,
                translate: self.translate,
                translateAnchor: self.translateAnchor,
                sortKey: self.sortKey,
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

    /// Modifier. Sets the ``shouldBeAntialised``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func shouldBeAntialised(_ value: Bool) -> Self {
        self.shouldBeAntialised = value

        return self
    }

    /// Modifier. Sets the ``color``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func color(_ value: UIColor) -> Self {
        self.color = value

        return self
    }

    /// Modifier. Sets the ``opacity``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func opacity(_ value: Double) -> Self {
        self.opacity = value

        return self
    }

    /// Modifier. Sets the ``outlineColor``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func outlineColor(_ value: UIColor) -> Self {
        self.outlineColor = value

        return self
    }

    /// Modifier. Sets the ``translate``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func translate(_ value: [Double]) -> Self {
        self.translate = value

        return self
    }

    /// Modifier. Sets the ``translateAnchor``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func translateAnchor(_ value: MTFillTranslateAnchor) -> Self {
        self.translateAnchor = value

        return self
    }

    /// Modifier. Sets the ``sortKey``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func sortKey(_ value: Double) -> Self {
        self.sortKey = value

        return self
    }

    /// Modifier. Sets the ``visibility``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func visibility(_ value: MTLayerVisibility) -> Self {
        self.visibility = value

        return self
    }

    /// Modifier. Sets the initial filter to apply upon add.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func withFilter(_ value: MTPropertyValue) -> Self {
        self.initialFilter = value
        return self
    }
}
