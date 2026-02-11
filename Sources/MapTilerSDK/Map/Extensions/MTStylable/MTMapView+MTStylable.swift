//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapView+MTStylable.swift
//  MapTilerSDK
//

import UIKit
import CoreLocation

extension MTMapView: MTStylable {
    /// Sets the value of the style's glyphs property.
    /// - Parameters:
    ///   - url: URL of the Glyph
    ///   - options: Supporting type to add validation to another style related type.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setGlyphs(
        url: URL,
        options: MTStyleSetterOptions?,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            SetGlyphs(url: url, options: options),
            completion: completionHandler
        )
    }

    /// Sets the map labels language.
    ///
    /// The language generally depends on the style. Whenever a label is not supported in the defined language,
    /// it falls back to MTLanguage.latin.
    /// - Parameters:
    ///   - language: The language to be applied.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setLanguage(_ language: MTLanguage, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetLanguage(language: language), completion: completionHandler)
        options?.setLanguage(language)
    }

    /// Sets the any combination of light values.
    /// - Parameters:
    ///   - light: Light properties to set.
    ///   - options: Supporting type to add validation to another style related type.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setLight(
        _ light: MTLight,
        options: MTStyleSetterOptions?,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetLight(light: light, options: options), completion: completionHandler)
    }

    /// Sets the sky configuration for the map.
    /// - Parameters:
    ///   - sky: Sky definition.
    ///   - options: Supporting type to add validation to another style related type.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setSky(
        _ sky: MTSky,
        options: MTStyleSetterOptions?,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetSky(sky: sky, options: options), completion: completionHandler)
    }

    /// Sets the space background for globe projection (cubemap/spacebox).
    /// - Parameters:
    ///   - space: Space configuration or a boolean to enable default.
    ///   - completionHandler: A handler block to execute when function finishes.
    /// - Note: Make sure space is enabled and projection is set to Globe before initializing the map via MTMapOptions.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setSpace(
        _ space: MTSpaceOption,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetSpace(space: space), completion: completionHandler)
        options?.setSpace(space)
    }

    /// Sets the atmospheric halo (glow) around the globe.
    /// - Parameters:
    ///   - halo: Halo configuration or a boolean to enable default.
    ///   - completionHandler: A handler block to execute when function finishes.
    /// - Note: Make sure halo is enabled and projection is set to Globe before initializing the map via MTMapOptions.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setHalo(
        _ halo: MTHaloOption,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetHalo(halo: halo), completion: completionHandler)
        options?.setHalo(halo)
    }

    /// Disables state transitions/animations for halo updates.
    /// - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func disableHaloAnimations(
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(DisableHaloAnimations(), completion: completionHandler)
    }

    /// Disables state transitions/animations for space updates.
    /// - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func disableSpaceAnimations(
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(DisableSpaceAnimations(), completion: completionHandler)
    }

    /// Sets the state of shouldRenderWorldCopies.
    ///
    /// If true , multiple copies of the world will be rendered side by side beyond -180 and 180 degrees longitude.
    /// If set to false:
    /// When the map is zoomed out far enough that a single representation of the world does not
    /// fill the map's entire container, there will be blank space beyond 180 and -180 degrees longitude.
    /// When the map is zoomed out far enough that a single representation of the world does not fill the
    /// map's entire container, there will be blank space beyond 180 and -180 degrees longitude.
    /// Features that cross 180 and -180 degrees longitude will be cut in two (with one portion on
    /// the right edge of the map and the other on the left edge of the map) at every zoom level.
    ///  - Parameters:
    ///     - shouldRenderWorldCopies: Boolean indicating whether world copies should be rendered.
    ///     - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setShouldRenderWorldCopies(
        _ shouldRenderWorldCopies: Bool,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            SetShouldRenderWorldCopies(shouldRenderWorldCopies: shouldRenderWorldCopies),
            completion: completionHandler
        )

        options?.setShouldRenderWorldCopies(shouldRenderWorldCopies)
    }

    /// Registers an image with the current style so it can be referenced by layers and annotations.
    /// - Parameters:
    ///   - name: Unique identifier for the image.
    ///   - image: Image to register.
    ///   - options: Additional configuration that controls how the image is rendered.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addImage(
        name: String,
        image: UIImage,
        options: MTStyleImageOptions? = nil,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        guard let command = AddImage(name: name, image: image, options: options) else {
            completionHandler?(.failure(.unknown(description: "Failed to encode image for addImage command.")))
            return
        }

        runCommand(command, completion: completionHandler)
    }

    /// Registers a sprite with the current style so it can be referenced by layers and annotations.
    /// - Parameters:
    ///   - id: Unique identifier for the sprite.
    ///   - url: URL pointing to the sprite resource.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addSprite(
        id: String,
        url: URL,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(AddSprite(id: id, url: url), completion: completionHandler)
    }

    /// Adds a marker to the map.
    /// - Parameters:
    ///    - marker: Marker to be added to the map.
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addMarker(_ marker: MTMarker, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(AddMarker(marker: marker), completion: completionHandler)
    }

    /// Adds multiple markers to the map.
    ///
    /// Batch adding is preferred way of adding multiple markers to the map.
    /// - Parameters:
    ///    - markers: Markers to be added to the map.
    ///    - withSingleIcon: Optional single image to use for all markers.
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addMarkers(
        _ markers: [MTMarker],
        withSingleIcon: UIImage?,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(AddMarkers(markers: markers, withSingleIcon: withSingleIcon), completion: completionHandler)
    }

    /// Removes a marker from the map.
    /// - Parameters:
    ///    - marker: Marker to be removed from the map.
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func removeMarker(_ marker: MTMarker, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(RemoveMarker(marker: marker), completion: completionHandler)
    }

    /// Removes multiple markers from the map.
    ///
    /// Batch removing is preferred way of removing multiple markers from the map.
    /// - Parameters:
    ///    - markers: Markers to be removed from the map.
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func removeMarkers(_ markers: [MTMarker], completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(RemoveMarkers(markers: markers), completion: completionHandler)
    }

    /// Adds a text popup to the map.
    /// - Parameters:
    ///    - popup: Popup to be added to the map.
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addTextPopup(_ popup: MTTextPopup, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        // Register for popup events before adding to map
        addContentDelegate(popup)
        runCommand(AddTextPopup(popup: popup), completion: completionHandler)
    }

    /// Removes a text popup from the map.
    /// - Parameters:
    ///    - popup: Popup to be removed from the map.
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func removeTextPopup(_ popup: MTTextPopup, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(RemoveTextPopup(popup: popup), completion: completionHandler)
    }

    /// Returns the projection currently active on the map.
    /// - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getProjection(completionHandler: ((Result<MTProjectionType, MTError>) -> Void)? = nil) {
        runCommandWithProjectionReturnValue(GetProjection(), completion: completionHandler)
    }

    /// Enables the globe projection visualization.
    /// - Parameters:
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func enableGlobeProjection(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(EnableGlobeProjection(), completion: completionHandler)

        options?.setProjection(.globe)

        // Do not implicitly create a space layer here; caller can setSpace explicitly
    }

    /// Enables the mercator projection visualization.
    /// - Parameters:
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func enableMercatorProjection(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(EnableMercatorProjection(), completion: completionHandler)
        options?.setProjection(.mercator)
    }

    /// Enables the 3D terrain visualization.
    /// - Parameters:
    ///    - exaggerationFactor: Factor for volume boosting.
    ///    - completionHandler: A handler block to execute when function finishes.
    /// - Note: Default is 1.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func enableTerrain(
        exaggerationFactor: Double = 1.0,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(EnableTerrain(exaggerationFactor: exaggerationFactor), completion: completionHandler)
        options?.setTerrainIsEnabled(true)
        options?.setTerrainExaggeration(exaggerationFactor)
    }

    /// Disables  the 3D terrain visualization.
    /// - Parameters:
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func disableTerrain(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(DisableTerrain(), completion: completionHandler)
        options?.setTerrainIsEnabled(false)
    }

    /// Sets the map's vertical field of view, in degrees.
    ///
    /// The internal camera has a default vertical field of view of a wide ~36.86 degrees. In globe mode,
    /// such a large FOV reduces the amount of the Earth that can be seen at once and exaggerates
    /// the central part, comparably to a fisheye lens. In many cases, a narrower FOV is preferable.
    ///  - Parameters:
    ///    - degrees: The vertical field of view to set, in degrees (0-180).
    ///    - completionHandler: A handler block to execute when function finishes.
    ///  - Note: Default is 36.87.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setVerticalFieldOfView(
        degrees: Double = 36.87,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            SetVerticalFieldOfView(
                degrees: degrees
            ),
            completion: completionHandler
        )
    }

    /// Returns boolean value indicating whether the source with provided id is loaded.
    ///  - Parameters:
    ///    - id: The id of the source.
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func isSourceLoaded(
        id: String,
        completionHandler: ((Result<Bool, MTError>) -> Void)? = nil
    ) {
        runCommandWithBoolReturnValue(
            IsSourceLoaded(
                sourceId: id
            ),
            completion: completionHandler
        )
    }

    /// Returns boolean value indicating whether all tiles required for the current viewport are loaded.
    ///  - Parameters:
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func areTilesLoaded(
        completionHandler: ((Result<Bool, MTError>) -> Void)? = nil
    ) {
        runCommandWithBoolReturnValue(
            AreTilesLoaded(),
            completion: completionHandler
        )
    }

    /// Returns boolean value indicating whether the map is fully loaded.
    ///  - Parameters:
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func isMapLoaded(
        completionHandler: ((Result<Bool, MTError>) -> Void)? = nil
    ) {
        runCommandWithBoolReturnValue(
            IsMapLoaded(),
            completion: completionHandler
        )
    }

    /// Returns boolean value indicating whether the map renders world copies.
    ///  - Parameters:
    ///    - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getRenderWorldCopies(
        completionHandler: ((Result<Bool, MTError>) -> Void)? = nil
    ) {
        runCommandWithBoolReturnValue(
            GetRenderWorldCopies(),
            completion: completionHandler
        )
    }

    package func getId(
        for referenceStyle: MTMapReferenceStyle,
        completionHandler: ((Result<String, MTError>) -> Void)? = nil
    ) {
        runCommandWithStringReturnValue(
            GetIdForReferenceStyle(
                referenceStyle: referenceStyle
            ),
            completion: completionHandler
        )
    }

    package func getId(
        for styleVariant: MTMapStyleVariant,
        completionHandler: ((Result<String, MTError>) -> Void)? = nil
    ) {
        runCommandWithStringReturnValue(
            GetIdForStyleVariant(styleVariant: styleVariant),
            completion: completionHandler
        )
    }

    package func getName(
        for referenceStyle: MTMapReferenceStyle,
        completionHandler: ((Result<String, MTError>) -> Void)? = nil
    ) {
        runCommandWithStringReturnValue(
            GetNameForReferenceStyle(referenceStyle: referenceStyle),
            completion: completionHandler
        )
    }

    package func getName(
        for styleVariant: MTMapStyleVariant,
        completionHandler: ((Result<String, MTError>) -> Void)? = nil
    ) {
        runCommandWithStringReturnValue(
            GetNameForStyleVariant(styleVariant: styleVariant),
            completion: completionHandler
        )
    }

    package func addSource(_ source: MTSource, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(AddSource(source: source), completion: completionHandler)
    }

    package func removeSource(_ source: MTSource, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(RemoveSource(source: source), completion: completionHandler)
    }

    package func addLayer(_ layer: MTLayer, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(AddLayer(layer: layer), completion: completionHandler)
    }

    package func addLayers(_ layers: [MTLayer], completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(AddLayers(layers: layers), completion: completionHandler)
    }

    package func removeLayer(_ layer: MTLayer, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(RemoveLayer(layer: layer), completion: completionHandler)
    }

    package func removeLayers(_ layers: [MTLayer], completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(RemoveLayers(layers: layers), completion: completionHandler)
    }

    // MARK: - Style property setters

    package func setFilter(
        forLayerId layerId: String,
        filter: MTPropertyValue,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetFilter(layerId: layerId, filter: filter), completion: completionHandler)
    }

    package func setLayoutProperty(
        forLayerId layerId: String,
        name: String,
        value: MTPropertyValue,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetLayoutProperty(layerId: layerId, name: name, value: value), completion: completionHandler)
    }

    package func setPaintProperty(
        forLayerId layerId: String,
        name: String,
        value: MTPropertyValue,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetPaintProperty(layerId: layerId, name: name, value: value), completion: completionHandler)
    }

    // MARK: - Typed property setters (overloads)
    /// Sets a symbol layout property using a typed key.
    /// - Parameters:
    ///   - layerId: Identifier of the target layer.
    ///   - property: Typed symbol layout property key.
    ///   - value: Property value or expression.
    ///   - completionHandler: Optional completion handler.
    package func setLayoutProperty(
        forLayerId layerId: String,
        property: MTSymbolLayoutProperty,
        value: MTPropertyValue,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        setLayoutProperty(
            forLayerId: layerId,
            name: property.rawValue,
            value: value,
            completionHandler: completionHandler
        )
    }

    /// Sets a circle paint property using a typed key.
    /// - Parameters:
    ///   - layerId: Identifier of the target layer.
    ///   - property: Typed circle paint property key.
    ///   - value: Property value or expression.
    ///   - completionHandler: Optional completion handler.
    package func setPaintProperty(
        forLayerId layerId: String,
        property: MTCirclePaintProperty,
        value: MTPropertyValue,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        setPaintProperty(
            forLayerId: layerId,
            name: property.rawValue,
            value: value,
            completionHandler: completionHandler
        )
    }

    /// Sets a symbol paint property using a typed key.
    /// - Parameters:
    ///   - layerId: Identifier of the target layer.
    ///   - property: Typed symbol paint property key.
    ///   - value: Property value or expression.
    ///   - completionHandler: Optional completion handler.
    package func setPaintProperty(
        forLayerId layerId: String,
        property: MTSymbolPaintProperty,
        value: MTPropertyValue,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        setPaintProperty(
            forLayerId: layerId,
            name: property.rawValue,
            value: value,
            completionHandler: completionHandler
        )
    }

    package func setDraggable(
        _ draggable: Bool,
        to marker: MTMarker,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetMarkerDraggable(marker: marker, draggable: draggable), completion: completionHandler)
    }

    package func setOffset(
        _ offset: Double,
        to marker: MTMarker,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetMarkerOffset(marker: marker, offset: offset), completion: completionHandler)
    }

    package func setRotation(
        _ rotation: Double,
        to marker: MTMarker,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetMarkerRotation(marker: marker, rotation: rotation), completion: completionHandler)
    }

    package func setRotationAlignment(
        _ alignment: MTMarkerRotationAlignment,
        to marker: MTMarker,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetMarkerRotationAlignment(marker: marker, alignment: alignment), completion: completionHandler)
    }

    package func togglePopup(
        for marker: MTMarker,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(ToggleMarkerPopup(marker: marker), completion: completionHandler)
    }

    package func setCoordinatesTo(_ marker: MTMarker, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetCoordinatesToMarker(marker: marker), completion: completionHandler)
    }

    package func setCoordinatesTo(_ popup: MTTextPopup, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetCoordinatesToTextPopup(popup: popup), completion: completionHandler)
    }

    package func setMaxWidth(
        _ maxWidth: Double,
        to popup: MTTextPopup,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetMaxWidthToTextPopup(popup: popup, maxWidth: maxWidth), completion: completionHandler)
    }

    package func setOffset(
        _ offset: Double,
        to popup: MTTextPopup,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetOffsetToTextPopup(popup: popup, offset: offset), completion: completionHandler)
    }

    package func setSubpixelPositioning(
        _ isEnabled: Bool,
        for popup: MTTextPopup,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            SetSubpixelPositioningToTextPopup(popup: popup, isEnabled: isEnabled),
            completion: completionHandler
        )
    }

    package func setText(
        _ text: String,
        to popup: MTTextPopup,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetTextToTextPopup(popup: popup, text: text), completion: completionHandler)
    }

    package func trackPointer(
        for popup: MTTextPopup,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(TrackTextPopupPointer(popup: popup), completion: completionHandler)
    }

    package func open(
        _ popup: MTTextPopup,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(OpenTextPopup(popup: popup), completion: completionHandler)
    }

    package func close(
        _ popup: MTTextPopup,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(CloseTextPopup(popup: popup), completion: completionHandler)
    }

    package func setURL(url: URL, to source: MTSource, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetUrlToSource(url: url, source: source), completion: completionHandler)
    }

    package func setData(data: URL, to source: MTSource, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetDataToSource(data: data, source: source), completion: completionHandler)
    }

    package func setTiles(
        tiles: [URL],
        to source: MTSource,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetTilesToSource(tiles: tiles, source: source), completion: completionHandler)
    }

    // MARK: - Image source helpers
    package func setCoordinates(
        _ coordinates: [CLLocationCoordinate2D],
        to source: MTImageSource,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let coords = coordinates.map { [$0.longitude, $0.latitude] }
        runCommand(SetCoordinatesToImageSource(source: source, coordinates: coords), completion: completionHandler)
    }

    package func updateImage(
        url: URL,
        coordinates: [CLLocationCoordinate2D],
        to source: MTImageSource,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let coords = coordinates.map { [$0.longitude, $0.latitude] }
        runCommand(
            UpdateImageInSource(source: source, url: url, coordinates: coords),
            completion: completionHandler
        )
    }

    // MARK: - Video source helpers
    package func setCoordinates(
        _ coordinates: [CLLocationCoordinate2D],
        to source: MTVideoSource,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let coords = coordinates.map { [$0.longitude, $0.latitude] }
        runCommand(SetCoordinatesToVideoSource(source: source, coordinates: coords), completion: completionHandler)
    }

    // Control playback on a video source
    package func play(_ source: MTVideoSource, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(PlayVideoSource(source: source), completion: completionHandler)
    }

    package func pause(_ source: MTVideoSource, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(PauseVideoSource(source: source), completion: completionHandler)
    }
}

// Concurrency: style property setters
extension MTMapView {
    public func setFilter(forLayerId layerId: String, filter: MTPropertyValue) async {
        await withCheckedContinuation { continuation in
            setFilter(forLayerId: layerId, filter: filter) { _ in
                continuation.resume()
            }
        }
    }

    public func setLayoutProperty(forLayerId layerId: String, name: String, value: MTPropertyValue) async {
        await withCheckedContinuation { continuation in
            setLayoutProperty(forLayerId: layerId, name: name, value: value) { _ in
                continuation.resume()
            }
        }
    }

    public func setPaintProperty(forLayerId layerId: String, name: String, value: MTPropertyValue) async {
        await withCheckedContinuation { continuation in
            setPaintProperty(forLayerId: layerId, name: name, value: value) { _ in
                continuation.resume()
            }
        }
    }

    // MARK: - Typed property setters (async)
    /// Sets a symbol layout property using a typed key (async).
    /// - Parameters:
    ///   - layerId: Identifier of the target layer.
    ///   - property: Typed symbol layout property key.
    ///   - value: Property value or expression.
    public func setLayoutProperty(
        forLayerId layerId: String,
        property: MTSymbolLayoutProperty,
        value: MTPropertyValue
    ) async {
        await setLayoutProperty(forLayerId: layerId, name: property.rawValue, value: value)
    }

    /// Sets a circle paint property using a typed key (async).
    /// - Parameters:
    ///   - layerId: Identifier of the target layer.
    ///   - property: Typed circle paint property key.
    ///   - value: Property value or expression.
    public func setPaintProperty(
        forLayerId layerId: String,
        property: MTCirclePaintProperty,
        value: MTPropertyValue
    ) async {
        await setPaintProperty(forLayerId: layerId, name: property.rawValue, value: value)
    }

    /// Sets a symbol paint property using a typed key (async).
    /// - Parameters:
    ///   - layerId: Identifier of the target layer.
    ///   - property: Typed symbol paint property key.
    ///   - value: Property value or expression.
    public func setPaintProperty(
        forLayerId layerId: String,
        property: MTSymbolPaintProperty,
        value: MTPropertyValue
    ) async {
        await setPaintProperty(forLayerId: layerId, name: property.rawValue, value: value)
    }
}

// Concurrency
extension MTMapView {
    /// Sets the value of the style's glyphs property.
    /// - Parameters:
    ///   - url: URL of the Glyph
    ///   - options: Supporting type to add validation to another style related type.
    public func setGlyphs(url: URL, options: MTStyleSetterOptions?) async {
        await withCheckedContinuation { continuation in
            setGlyphs(url: url, options: options) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the map labels language.
    ///
    /// The language generally depends on the style. Whenever a label is not supported in the defined language,
    /// it falls back to MTLanguage.latin.
    /// - Parameters:
    ///   - language: The language to be applied.
    public func setLanguage(_ language: MTLanguage) async {
        await withCheckedContinuation { continuation in
            setLanguage(language) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the any combination of light values.
    /// - Parameters:
    ///   - light: Light properties to set.
    ///   - options: Supporting type to add validation to another style related type.
    public func setLight(_ light: MTLight, options: MTStyleSetterOptions?) async {
        await withCheckedContinuation { continuation in
            setLight(light, options: options) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the sky configuration for the map.
    /// - Parameters:
    ///   - sky: Sky definition.
    ///   - options: Supporting type to add validation to another style related type.
    public func setSky(_ sky: MTSky, options: MTStyleSetterOptions?) async {
        await withCheckedContinuation { continuation in
            setSky(sky, options: options) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the space background for globe projection (cubemap/spacebox).
    /// - Parameters:
    ///   - space: Space configuration or a boolean to enable default.
    /// - Note: Make sure space is enabled and projection is set to Globe before initializing the map via MTMapOptions.
    public func setSpace(_ space: MTSpaceOption) async {
        await withCheckedContinuation { continuation in
            setSpace(space) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the state of shouldRenderWorldCopies.
    ///
    /// If true , multiple copies of the world will be rendered side by side beyond -180 and 180 degrees longitude.
    /// If set to false:
    /// When the map is zoomed out far enough that a single representation of the world does not
    /// fill the map's entire container, there will be blank space beyond 180 and -180 degrees longitude.
    /// When the map is zoomed out far enough that a single representation of the world does not fill the
    /// map's entire container, there will be blank space beyond 180 and -180 degrees longitude.
    /// Features that cross 180 and -180 degrees longitude will be cut in two (with one portion on
    /// the right edge of the map and the other on the left edge of the map) at every zoom level.
    ///  - Parameters:
    ///     - shouldRenderWorldCopies: Boolean indicating whether world copies should be rendered.
    public func setShouldRenderWorldCopies(_ shouldRenderWorldCopies: Bool) async {
        await withCheckedContinuation { continuation in
            setShouldRenderWorldCopies(shouldRenderWorldCopies) { _ in
                continuation.resume()
            }
        }
    }

    /// Registers an image with the current style so it can be referenced by layers and annotations.
    /// - Parameters:
    ///   - name: Unique identifier for the image.
    ///   - image: Image to register.
    ///   - options: Additional configuration that controls how the image is rendered.
    public func addImage(name: String, image: UIImage, options: MTStyleImageOptions? = nil) async {
        await withCheckedContinuation { continuation in
            addImage(name: name, image: image, options: options) { _ in
                continuation.resume()
            }
        }
    }

    /// Registers a sprite with the current style so it can be referenced by layers and annotations.
    /// - Parameters:
    ///   - id: Unique identifier for the sprite.
    ///   - url: URL pointing to the sprite resource.
    public func addSprite(id: String, url: URL) async {
        await withCheckedContinuation { continuation in
            addSprite(id: id, url: url) { _ in
                continuation.resume()
            }
        }
    }

    /// Adds a marker to the map.
    /// - Parameters:
    ///    - marker: Marker to be added to the map.
    public func addMarker(_ marker: MTMarker) async {
        await withCheckedContinuation { continuation in
            addMarker(marker) { _ in
                continuation.resume()
            }
        }
    }

    /// Adds multiple markers to the map.
    ///
    /// Batch adding is preferred way of adding multiple markers to the map.
    /// - Parameters:
    ///    - markers: Markers to be added to the map.
    ///    - withSingleIcon: Optional single image to use for all markers.
    public func addMarkers(_ markers: [MTMarker], withSingleIcon: UIImage?) async {
        await withCheckedContinuation { continuation in
            addMarkers(markers, withSingleIcon: withSingleIcon) { _ in
                continuation.resume()
            }
        }
    }

    /// Removes a marker from the map.
    /// - Parameters:
    ///    - marker: Marker to be removed from the map.
    public func removeMarker(_ marker: MTMarker) async {
        await withCheckedContinuation { continuation in
            removeMarker(marker) { _ in
                continuation.resume()
            }
        }
    }

    /// Removes multiple markers from the map.
    ///
    /// Batch removing is preferred way of removing multiple markers from the map.
    /// - Parameters:
    ///    - markers: Markers to be removed from the map.
    public func removeMarkers(_ markers: [MTMarker]) async {
        await withCheckedContinuation { continuation in
            removeMarkers(markers) { _ in
                continuation.resume()
            }
        }
    }

    /// Adds a text popup to the map.
    /// - Parameters:
    ///    - popup: Popup to be added to the map.
    public func addTextPopup(_ popup: MTTextPopup) async {
        await withCheckedContinuation { continuation in
            addTextPopup(popup) { _ in
                continuation.resume()
            }
        }
    }

    /// Removes a text popup from the map.
    /// - Parameters:
    ///    - marker: Popup to be removed from the map.
    public func removeTextPopup(_ popup: MTTextPopup) async {
        await withCheckedContinuation { continuation in
            removeTextPopup(popup) { _ in
                continuation.resume()
            }
        }
    }

    /// Returns the projection currently active on the map.
    public func getProjection() async -> MTProjectionType {
        await withCheckedContinuation { continuation in
            getProjection { [weak self] result in
                switch result {
                case .success(let projection):
                    continuation.resume(returning: projection)
                case .failure:
                    let fallback = self?.options?.projection ?? .mercator
                    continuation.resume(returning: fallback)
                }
            }
        }
    }

    /// Enables the globe projection visualization.
    public func enableGlobeProjection() async {
        await withCheckedContinuation { continuation in
            enableGlobeProjection { _ in
                continuation.resume()
            }
        }
    }

    /// Enables the mercator projection visualization.
    public func enableMercatorProjection() async {
        await withCheckedContinuation { continuation in
            enableMercatorProjection { _ in
                continuation.resume()
            }
        }
    }

    /// Enables the 3D terrain visualization.
    /// - Parameters:
    ///    - exaggerationFactor: Factor for volume boosting.
    /// - Note: Default is 1.
    public func enableTerrain(exaggerationFactor: Double = 1.0) async {
        await withCheckedContinuation { continuation in
            enableTerrain(exaggerationFactor: exaggerationFactor) { _ in
                continuation.resume()
            }
        }
    }

    /// Disables  the 3D terrain visualization.
    public func disableTerrain() async {
        await withCheckedContinuation { continuation in
            disableTerrain { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the map's vertical field of view, in degrees.
    ///
    /// The internal camera has a default vertical field of view of a wide ~36.86 degrees. In globe mode,
    /// such a large FOV reduces the amount of the Earth that can be seen at once and exaggerates
    /// the central part, comparably to a fisheye lens. In many cases, a narrower FOV is preferable.
    ///  - Parameters:
    ///    - degrees: The vertical field of view to set, in degrees (0-180).
    ///  - Note: Default is 36.87.
    public func setVerticalFieldOfView(degrees: Double = 36.87) async {
        await withCheckedContinuation { continuation in
            setVerticalFieldOfView(degrees: degrees) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the atmospheric halo (glow) around the globe.
    /// - Parameters:
    ///   - halo: Halo configuration or a boolean to enable default.
    /// - Note: Make sure halo is enabled and projection is set to Globe before initializing the map via MTMapOptions.
    public func setHalo(_ halo: MTHaloOption) async {
        await withCheckedContinuation { continuation in
            setHalo(halo) { _ in
                continuation.resume()
            }
        }
    }

    /// Disables state transitions/animations for halo updates.
    public func disableHaloAnimations() async {
        await withCheckedContinuation { continuation in
            disableHaloAnimations { _ in
                continuation.resume()
            }
        }
    }

    /// Disables state transitions/animations for space updates.
    public func disableSpaceAnimations() async {
        await withCheckedContinuation { continuation in
            disableSpaceAnimations { _ in
                continuation.resume()
            }
        }
    }

    /// Returns boolean value indicating whether the source with provided id is loaded.
    ///  - Parameters:
    ///    - id: The id of the source.
    public func isSourceLoaded(id: String) async -> Bool {
        await withCheckedContinuation { continuation in
            isSourceLoaded(id: id) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        }
    }

    /// Returns boolean value indicating whether all tiles required for the current viewport are loaded.
    public func areTilesLoaded() async -> Bool {
        await withCheckedContinuation { continuation in
            areTilesLoaded { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        }
    }

    /// Returns boolean value indicating whether the map is fully loaded.
    public func isMapLoaded() async -> Bool {
        await withCheckedContinuation { continuation in
            isMapLoaded { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        }
    }

    /// Returns boolean value indicating whether the map renders world copies.
    public func getRenderWorldCopies() async -> Bool {
        await withCheckedContinuation { continuation in
            getRenderWorldCopies { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        }
    }

    package func setURL(url: URL, to source: MTSource) async {
        await withCheckedContinuation { continuation in
            setURL(url: url, to: source) { _ in
                continuation.resume()
            }
        }
    }

    package func setData(data: URL, to source: MTSource) async {
        await withCheckedContinuation { continuation in
            setData(data: data, to: source) { _ in
                continuation.resume()
            }
        }
    }

    package func setTiles(tiles: [URL], to source: MTSource) async {
        await withCheckedContinuation { continuation in
            setTiles(tiles: tiles, to: source) { _ in
                continuation.resume()
            }
        }
    }
}
