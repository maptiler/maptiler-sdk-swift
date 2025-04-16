//
//  MTLineLayer+DSL.swift
//  MapTilerSDK
//

import UIKit

// DSL
extension MTLineLayer {
    /// Adds layer to map DSL style.
    ///
    /// Prefer ``MTStyle/addLayer(_:)`` on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let layer = MTLineLayer(
                identifier: self.identifier,
                sourceIdentifier: self.sourceIdentifier,
                maxZoom: self.maxZoom,
                minZoom: self.minZoom,
                sourceLayer: self.sourceLayer,
                blur: self.blur,
                cap: self.cap,
                color: self.color,
                dashArray: self.dashArray,
                gapWidth: self.gapWidth,
                gradient: self.gradient,
                join: self.join,
                miterLimit: self.miterLimit,
                offset: self.offset,
                opacity: self.opacity,
                roundLimit: self.roundLimit,
                sortKey: self.sortKey,
                translate: self.translate,
                translateAnchor: self.translateAnchor,
                width: self.width,
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

    /// Modifier. Sets the ``blur``.
    @discardableResult
    public func blur(_ value: Double) -> Self {
        self.blur = value

        return self
    }

    /// Modifier. Sets the ``cap``.
    @discardableResult
    public func cap(_ value: MTLineCap) -> Self {
        self.cap = value

        return self
    }

    /// Modifier. Sets the ``color``.
    @discardableResult
    public func color(_ value: UIColor) -> Self {
        self.color = value

        return self
    }

    /// Modifier. Sets the ``dashArray``.
    @discardableResult
    public func dashArray(_ value: [Double]) -> Self {
        self.dashArray = value

        return self
    }

    /// Modifier. Sets the ``gapWidth``.
    @discardableResult
    public func gapWidth(_ value: Double) -> Self {
        self.gapWidth = value

        return self
    }

    /// Modifier. Sets the ``gradient``.
    @discardableResult
    public func gradient(_ value: UIColor) -> Self {
        self.gradient = value

        return self
    }

    /// Modifier. Sets the ``join``.
    @discardableResult
    public func join(_ value: MTLineJoin) -> Self {
        self.join = value

        return self
    }

    /// Modifier. Sets the ``miterLimit``.
    @discardableResult
    public func miterLimit(_ value: Double) -> Self {
        self.miterLimit = value

        return self
    }

    /// Modifier. Sets the ``offset``.
    @discardableResult
    public func offset(_ value: Double) -> Self {
        self.offset = value

        return self
    }

    /// Modifier. Sets the ``opacity``.
    @discardableResult
    public func opacity(_ value: Double) -> Self {
        self.opacity = value

        return self
    }

    /// Modifier. Sets the ``roundLimit``.
    @discardableResult
    public func roundLimit(_ value: Double) -> Self {
        self.roundLimit = value

        return self
    }

    /// Modifier. Sets the ``sortKey``.
    @discardableResult
    public func sortKey(_ value: Double) -> Self {
        self.sortKey = value

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
    public func translateAnchor(_ value: MTLineTranslateAnchor) -> Self {
        self.translateAnchor = value

        return self
    }

    /// Modifier. Sets the ``width``.
    @discardableResult
    public func width(_ value: Double) -> Self {
        self.width = value

        return self
    }

    /// Modifier. Sets the ``visibility``.
    @discardableResult
    public func visibility(_ value: MTLayerVisibility) -> Self {
        self.visibility = value

        return self
    }
}
