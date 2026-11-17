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

    /// Sets the map labels secondary language.
    /// - Parameters:
    ///    - language: The language to be applied.
    func setSecondaryLanguage(_ language: MTLanguage) async

    /// Sets the map sprite.
    /// - Parameters:
    ///    - url: The URL pointing to the sprite resource.
    func setSprite(_ url: URL) async

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

    /// Removes a previously added image by name.
    /// Use to clean up icons no longer referenced by layers.
    /// - Parameters:
    ///   - name: Unique identifier for the image to remove.
    func removeImage(name: String) async

    /// Registers a sprite with the current style so it can be referenced by layers and annotations.
    /// - Parameters:
    ///   - id: Unique identifier for the sprite.
    ///   - url: URL pointing to the sprite resource.
    func addSprite(id: String, url: URL) async

    /// Removes a sprite from the current style.
    /// Use to detach a sprite and free related resources.
    /// - Parameters:
    ///   - id: Unique identifier for the sprite.
    func removeSprite(id: String) async

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

    /// Returns true if the current projection is globe; otherwise false.
    func isGlobeProjection() async -> Bool

    /// Enables the 3D terrain visualization.
    /// - Parameters:
    ///    - exaggerationFactor: Factor for volume boosting.
    /// - Note: Default is 1.
    func enableTerrain(exaggerationFactor: Double) async

    /// Disables  the 3D terrain visualization.
    func disableTerrain() async

    /// Sets the terrain exaggeration.
    /// - Parameters:
    ///    - exaggeration: The new exaggeration factor.
    ///    - animate: Whether to animate the transition. Defaults to `true`.
    func setTerrainExaggeration(_ exaggeration: Double, animate: Bool) async

    /// Sets the animation duration of the terrain transitions.
    /// - Parameters:
    ///    - duration: The duration in milliseconds.
    func setTerrainAnimationDuration(_ duration: Double) async

    /// Sets the 3D terrain on the map.
    /// - Parameters:
    ///    - sourceId: The ID of the terrain source.
    ///    - exaggeration: Factor for volume boosting.
    func setTerrain(sourceId: String, exaggeration: Double?) async

    /// Removes the 3D terrain from the map.
    func setTerrain() async

    /// Returns true if 3D terrain visualization is enabled.
    func hasTerrain() async -> Bool

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

    /// Returns the filter applied to the specified layer.
    func getFilter(layerId: String) async -> MTPropertyValue?

    /// Returns the map's glyphs URL.
    func getGlyphs() async -> String?

    /// Returns an array of layer IDs representing the current layer order.
    func getLayersOrder() async -> [String]

    /// Returns the value of a layout property in the specified layer.
    func getLayoutProperty(layerId: String, name: String) async -> MTPropertyValue?

    /// Returns the map's light configuration.
    func getLight() async -> MTLight?

    /// Returns the value of a paint property in the specified layer.
    func getPaintProperty(layerId: String, name: String) async -> MTPropertyValue?

    /// Returns the sky configuration.
    func getSky() async -> MTSky?

    /// Returns the source with the given ID.
    func getSource(id: String) async -> String?

    /// Returns the map's sprite URL.
    func getSprite() async -> String?

    /// Returns the current map style.
    func getStyle() async -> String?

    /// Returns the 3D terrain specification.
    func getTerrain() async -> MTTerrain?

    /// Returns the current terrain exaggeration.
    func getTerrainExaggeration() async -> Double

    /// Returns the vertical field of view in degrees.
    func getVerticalFieldOfView() async -> Double

    /// Returns whether the language is updated.
    func isLanguageUpdated() async -> Bool
    /// Sets the state of a feature.
    /// - Parameters:
    ///   - feature: The feature identifier.
    ///   - state: The state dictionary to apply.
    func setFeatureState(_ feature: MTFeatureIdentifier, state: [String: MTFeatureStateValue]) async

    /// Gets the state of a feature.
    /// - Parameters:
    ///   - feature: The feature identifier.
    /// - Returns: The state dictionary of the feature.
    func getFeatureState(_ feature: MTFeatureIdentifier) async -> [String: MTFeatureStateValue]?

    /// Removes the state of a feature.
    /// - Parameters:
    ///   - feature: The feature identifier.
    ///   - key: The key of the state to remove. If nil, all state properties are removed.
    func removeFeatureState(_ feature: MTFeatureIdentifier, key: String?) async
}
