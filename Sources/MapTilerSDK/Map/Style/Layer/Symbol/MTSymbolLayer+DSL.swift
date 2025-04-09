//
//  MTSymbolLayer+DSL.swift
//  MapTilerSDK
//

import UIKit

// DSL
extension MTSymbolLayer {
    /// Adds layer to map DSL style.
    ///
    /// Prefer mapView.style.addLayer instead.
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

    /// Modifier. Sets the ``icon``.
    public func icon(_ value: UIImage) -> Self {
        self.icon = value

        return self
    }

    /// Modifier. Sets the ``visibility``.
    @discardableResult
    public func visibility(_ value: MTLayerVisibility) -> Self {
        self.visibility = value

        return self
    }
}
