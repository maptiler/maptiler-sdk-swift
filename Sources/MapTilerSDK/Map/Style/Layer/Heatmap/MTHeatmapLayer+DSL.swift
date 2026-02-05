//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTHeatmapLayer+DSL.swift
//  MapTilerSDK
//

import Foundation

// DSL
extension MTHeatmapLayer {
    /// Adds layer to map DSL style.
    ///
    /// Prefer `MTStyle/addLayer(_:)` on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let layer = MTHeatmapLayer(
                identifier: self.identifier,
                sourceIdentifier: self.sourceIdentifier,
                maxZoom: self.maxZoom,
                minZoom: self.minZoom,
                sourceLayer: self.sourceLayer,
                color: self.color,
                intensity: self.intensity,
                opacity: self.opacity,
                radius: self.radius,
                weight: self.weight,
                visibility: self.visibility
            )
            layer.filterExpression = self.filterExpression
            layer.initialFilter = self.initialFilter

            try await mapView.style?.addLayer(layer)
        }
    }
}
