//
//  MTFillLayer+DSL.swift
//  MapTilerSDK
//

import UIKit

// DSL
extension MTFillLayer {
    /// Adds layer to map DSL style.
    ///
    /// Prefer mapView.style.addLayer instead.
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
    @discardableResult
    public func maxZoom(_ value: Double) -> Self {
        self.maxZoom = value

        return self
    }

    /// Modifier. Sets the ``minZoom``.
    @discardableResult
    public func minZoom(_ value: Double) -> Self {
        self.maxZoom = value

        return self
    }

    /// Modifier. Sets the ``sourceLayer``.
    @discardableResult
    public func sourceLayer(_ value: String) -> Self {
        self.sourceLayer = value

        return self
    }

    /// Modifier. Sets the ``shouldBeAntialised``.
    @discardableResult
    public func shouldBeAntialised(_ value: Bool) -> Self {
        self.shouldBeAntialised = value

        return self
    }

    /// Modifier. Sets the ``color``.
    @discardableResult
    public func color(_ value: UIColor) -> Self {
        self.color = value

        return self
    }

    /// Modifier. Sets the ``opacity``.
    @discardableResult
    public func opacity(_ value: Double) -> Self {
        self.opacity = value

        return self
    }

    /// Modifier. Sets the ``outlineColor``.
    @discardableResult
    public func outlineColor(_ value: UIColor) -> Self {
        self.outlineColor = value

        return self
    }

    /// Modifier. Sets the ``translate``.
    @discardableResult
    public func translate(_ value: [Double]) -> Self {
        self.translate = value

        return self
    }

    /// Modifier. Sets the ``translateAnchor``.
    @discardableResult
    public func translateAnchor(_ value: MTFillTranslateAnchor) -> Self {
        self.translateAnchor = value

        return self
    }

    /// Modifier. Sets the ``sortKey``.
    @discardableResult
    public func sortKey(_ value: Double) -> Self {
        self.sortKey = value

        return self
    }

    /// Modifier. Sets the ``visibility``.
    @discardableResult
    public func visibility(_ value: MTLayerVisibility) -> Self {
        self.visibility = value

        return self
    }
}
