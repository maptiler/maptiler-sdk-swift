//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTRasterLayer+DSL.swift
//  MapTilerSDK
//

import Foundation

// DSL
extension MTRasterLayer {
    /// Adds layer to map DSL style.
    ///
    /// Prefer `MTStyle/addLayer(_:)` on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let layer = MTRasterLayer(
                identifier: self.identifier,
                sourceIdentifier: self.sourceIdentifier,
                maxZoom: self.maxZoom,
                minZoom: self.minZoom,
                sourceLayer: self.sourceLayer,
                brightnessMax: self.brightnessMax,
                brightnessMin: self.brightnessMin,
                contrast: self.contrast,
                fadeDuration: self.fadeDuration,
                hueRotate: self.hueRotate,
                opacity: self.opacity,
                resampling: self.resampling,
                saturation: self.saturation,
                visibility: self.visibility
            )

            try await mapView.style?.addLayer(layer)
        }
    }

    /// Modifier. Sets the `maxZoom`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func maxZoom(_ value: Double) -> Self {
        self.maxZoom = value
        return self
    }

    /// Modifier. Sets the `minZoom`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func minZoom(_ value: Double) -> Self {
        self.minZoom = value
        return self
    }

    /// Modifier. Sets the `sourceLayer`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func sourceLayer(_ value: String) -> Self {
        self.sourceLayer = value
        return self
    }

    /// Modifier. Sets the `brightnessMax`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func brightnessMax(_ value: Double) -> Self {
        self.brightnessMax = value
        return self
    }

    /// Modifier. Sets the `brightnessMin`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func brightnessMin(_ value: Double) -> Self {
        self.brightnessMin = value
        return self
    }

    /// Modifier. Sets the `contrast`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func contrast(_ value: Double) -> Self {
        self.contrast = value
        return self
    }

    /// Modifier. Sets the `fadeDuration`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func fadeDuration(_ value: Double) -> Self {
        self.fadeDuration = value
        return self
    }

    /// Modifier. Sets the `hueRotate`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func hueRotate(_ value: Double) -> Self {
        self.hueRotate = value
        return self
    }

    /// Modifier. Sets the `opacity`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func opacity(_ value: Double) -> Self {
        self.opacity = value
        return self
    }

    /// Modifier. Sets the `resampling`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func resampling(_ value: MTRasterResampling) -> Self {
        self.resampling = value
        return self
    }

    /// Modifier. Sets the `saturation`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func saturation(_ value: Double) -> Self {
        self.saturation = value
        return self
    }

    /// Modifier. Sets the `visibility`.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func visibility(_ value: MTLayerVisibility) -> Self {
        self.visibility = value
        return self
    }
}
