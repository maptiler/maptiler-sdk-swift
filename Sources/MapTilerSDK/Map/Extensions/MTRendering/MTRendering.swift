//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTRendering.swift
//  MapTilerSDK
//

/// Defines methods for adjusting rendering parameters.
@MainActor
public protocol MTRendering {
    /// Returns the pixel ratio currently used by the map.
    func getPixelRatio() async -> Double

    /// Sets the pixel ratio to use when rendering the map.
    /// - Parameter pixelRatio: Pixel ratio value to apply.
    func setPixelRatio(_ pixelRatio: Double) async

    /// Trigger the rendering of a single frame. Use this method with custom layers to repaint the map
    /// when the layer changes. Calling this multiple times before the next frame is rendered will still
    /// result in only a single frame being rendered.
    func triggerRepaint() async

    /// Schedules a re‑render of the map.
    func redraw() async

    /// Displays tile boundaries on the map.
    /// - Parameter show: A boolean value indicating whether to show tile boundaries.
    func setShowTileBoundaries(_ show: Bool) async

    /// Displays padding on the map.
    /// - Parameter show: A boolean value indicating whether to show padding.
    func setShowPadding(_ show: Bool) async

    /// Displays the overdraw inspector on the map.
    /// - Parameter show: A boolean value indicating whether to show the overdraw inspector.
    func setShowOverdrawInspector(_ show: Bool) async

    /// Displays collision boxes on the map.
    /// - Parameter show: A boolean value indicating whether to show collision boxes.
    func setShowCollisionBoxes(_ show: Bool) async

    /// Sets the maximum number of images loaded in parallel.
    /// - Parameter maxParallelImageRequests: The maximum number of images.
    func setMaxParallelImageRequests(_ maxParallelImageRequests: Int) async

    /// Sets the map's RTL text plugin.
    /// - Parameters:
    ///   - pluginURL: URL pointing to the Mapbox RTL text plugin source.
    ///   - deferred: A boolean indicating if the plugin evaluation should be deferred.
    func setRTLTextPlugin(pluginURL: String, deferred: Bool) async
}
