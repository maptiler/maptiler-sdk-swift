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

    /// Modifier. Sets the ``visibility``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func visibility(_ value: MTLayerVisibility) -> Self {
        self.visibility = value

        return self
    }
}
