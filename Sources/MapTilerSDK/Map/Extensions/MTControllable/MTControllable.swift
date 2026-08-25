//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTControllable.swift
//  MapTilerSDK
//

import Foundation

/// Defines methods for adding the map controls.
@MainActor
public protocol MTControllable {
    /// Adds the MapTiler logo control to the map.
    ///  - Parameters:
    ///     - position: Map position to add the control to.
    func addMapTilerLogoControl(position: MTMapCorner) async

    /// Adds the logo control to the map.
    ///  - Parameters:
    ///     - logoURL: URL of the logo image resource.
    ///     - linkURL: URL of the anchor link.
    ///     - position: Map position to add the control to.
    func addLogoControl(name: String, logoURL: URL, linkURL: URL, position: MTMapCorner) async

    /// Adds the navigation control to the map.
    ///  - Parameters:
    ///     - position: Map position to add the control to.
    ///     - showCompass: If true the compass button is included.
    ///     - showZoom: If true the zoom-in and zoom-out buttons are included.
    ///     - visualizePitch: If true the pitch is visualized by rotating X-axis of compass.
    func addNavigationControl(position: MTMapCorner, showCompass: Bool, showZoom: Bool, visualizePitch: Bool) async

    /// Toggles the compass visibility on the navigation control.
    /// - Parameters:
    ///   - showCompass: If true the compass button is included.
    func navigationControlShowCompass(_ showCompass: Bool) async

    /// Toggles the zoom controls visibility on the navigation control.
    /// - Parameters:
    ///   - showZoom: If true the zoom-in and zoom-out buttons are included.
    func navigationControlShowZoom(_ showZoom: Bool) async

    /// Toggles the pitch visualization on the navigation control compass.
    /// - Parameters:
    ///   - visualizePitch: If true the pitch is visualized by rotating X-axis of compass.
    func navigationControlVisualizePitch(_ visualizePitch: Bool) async

    /// Adds the terrain control to the map.
    /// - Parameters:
    ///   - position: Map position to add the control to.
    func addTerrainControl(position: MTMapCorner) async
}
