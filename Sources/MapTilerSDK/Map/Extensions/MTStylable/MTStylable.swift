//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTStylable.swift
//  MapTilerSDK
//

import Foundation
import UIKit

/// Defines methods for map styling methods.
@MainActor
public protocol MTStylable {
    /// Sets the value of the style's glyphs property.
    /// - Parameters:
    ///    - url: URL pointing to the glyphs resource.
    ///    - options: Style setter options.
    func setGlyphs(url: URL, options: MTStyleSetterOptions?) async

    /// Sets the map labels language.
    ///
    /// The language generally depends on the style. Whenever a label is not supported in the defined language,
    ///  it falls back to ``Latin``.
    /// - Parameters:
    ///    - language: The language to be applied.
    func setLanguage(_ language: MTLanguage) async

    /// Sets the any combination of light values.
    /// - Parameters:
    ///    - light: Light options.
    ///    - options: Style setter options.
    func setLight(_ light: MTLight, options: MTStyleSetterOptions?) async

    /// Sets the sky configuration for the map.
    /// - Parameters:
    ///   - sky: Sky definition.
    ///   - options: Style setter options.
    func setSky(_ sky: MTSky, options: MTStyleSetterOptions?) async

    /// Sets the space background for globe projection (cubemap/spacebox).
    /// - Parameters:
    ///    - space: Space configuration or a boolean to enable default.
    ///
    /// - Note: Make sure space is enabled and projection is set to Globe before initializing the map via MTMapOptions.
    func setSpace(_ space: MTSpaceOption) async

    /// Sets the atmospheric halo (glow) around the globe.
    /// - Parameters:
    ///    - halo: Halo configuration or a boolean to enable default.
    /// - Note: Make sure halo is enabled and projection is set to Globe before initializing the map via MTMapOptions.
    func setHalo(_ halo: MTHaloOption) async

    /// Disables state transitions/animations for halo updates.
    func disableHaloAnimations() async

    /// Disables state transitions/animations for space updates.
    func disableSpaceAnimations() async

    /// Sets the state where multiple copies of the world will be rendered
    /// side by side beyond -180 and 180 degrees longitude.
    /// - Parameters:
    ///    - shouldRenderWorldCopies: Boolean indicating whether world copies should be rendered.
    func setShouldRenderWorldCopies(_ shouldRenderWorldCopies: Bool) async

    /// Registers an image with the current style so it can be referenced by layers and annotations.
    /// - Parameters:
    ///   - name: Unique identifier for the image.
    ///   - image: Image to register.
    ///   - options: Additional configuration that controls how the image is rendered.
    func addImage(name: String, image: UIImage, options: MTStyleImageOptions?) async

    /// Registers a sprite with the current style so it can be referenced by layers and annotations.
    /// - Parameters:
    ///   - id: Unique identifier for the sprite.
    ///   - url: URL pointing to the sprite resource.
    func addSprite(id: String, url: URL) async

    /// Adds the marker to the map.
    /// - Parameters:
    ///    - marker: Marker to add to the map.
    func addMarker(_ marker: MTMarker) async

    /// Adds multiple markers to the map.
    ///
    /// Batch adding is preferred way of adding multiple markers to the map.
    /// - Parameters:
    ///    - markers: Markers to be added to the map.
    ///    - withSingleIcon: Optional single image to use for all markers.
    func addMarkers(_ markers: [MTMarker], withSingleIcon: UIImage?) async

    /// Removes a marker from the map.
    /// - Parameters:
    ///    - marker: Marker to be removed from the map.
    func removeMarker(_ marker: MTMarker) async

    /// Removes multiple markers from the map.
    ///
    /// Batch removing is preferred way of removing multiple markers from the map.
    /// - Parameters:
    ///    - markers: Markers to be removed from the map.
    func removeMarkers(_ markers: [MTMarker]) async

    /// Enables the globe projection visualization.
    func enableGlobeProjection() async

    /// Enables the mercator projection visualization.
    func enableMercatorProjection() async

    /// Enables the 3D terrain visualization.
    /// - Parameters:
    ///    - exaggerationFactor: Factor for volume boosting.
    /// - Note: Default is 1.
    func enableTerrain(exaggerationFactor: Double) async

    /// Disables  the 3D terrain visualization.
    func disableTerrain() async

    /// Sets the map's vertical field of view, in degrees.
    ///
    /// The internal camera has a default vertical field of view of a wide ~36.86 degrees. In globe mode,
    /// such a large FOV reduces the amount of the Earth that can be seen at once and exaggerates
    /// the central part, comparably to a fisheye lens. In many cases, a narrower FOV is preferable.
    ///  - Parameters:
    ///    - degrees: The vertical field of view to set, in degrees (0-180).
    ///  - Note: Default is 36.87.
    func setVerticalFieldOfView(degrees: Double) async

    /// Returns boolean value indicating whether the source with provided id is loaded.
    ///  - Parameters:
    ///    - id: The id of the source.
    func isSourceLoaded(id: String) async -> Bool
}
