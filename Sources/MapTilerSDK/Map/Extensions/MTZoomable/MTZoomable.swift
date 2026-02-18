//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTZoomable.swift
//  MapTilerSDK
//

/// Defines methods for manipulating zoom level.
@MainActor
public protocol MTZoomable {
    /// Increases the map's zoom level by 1.
    func zoomIn() async

    /// Decreases the map's zoom level by 1.
    func zoomOut() async

    /// Returns the map's current zoom level.
    func getZoom() async -> Double

    /// Sets the map's zoom level.
    ///  - Parameters:
    ///   - zoom: The zoom level to set (0-20).
    func setZoom(_ zoom: Double) async

    /// Zooms the map to the specified zoom level with optional animation options.
    /// - Parameters:
    ///   - zoom: The zoom level to transition to.
    ///   - options: Animation options.
    func zoomTo(_ zoom: Double, options: MTAnimationOptions?) async
}
