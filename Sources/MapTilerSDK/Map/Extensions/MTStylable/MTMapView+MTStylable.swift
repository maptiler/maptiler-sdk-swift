//
//  MTMapView+MTStylable.swift
//  MapTilerSDK
//

import UIKit

extension MTMapView: MTStylable {
    /// Sets the value of the style's glyphs property.
    /// - Parameters:
    ///   - url: URL of the Glyph
    ///   - options: Supporting type to add validation to another style related type.
    public func setGlyphs(url: URL, options: MTStyleSetterOptions?) async {
        await runCommand(SetGlyphs(url: url, options: options))
    }

    /// Sets the map labels language.
    ///
    /// The language generally depends on the style. Whenever a label is not supported in the defined language,
    /// it falls back to MTLanguage.latin.
    /// - Parameters:
    ///   - language: The language to be applied.
    public func setLanguage(_ language: MTLanguage) async {
        await runCommand(SetLanguage(language: language))
    }

    /// Sets the any combination of light values.
    /// - Parameters:
    ///   - light: Light properties to set.
    ///   - options: Supporting type to add validation to another style related type.
    public func setLight(_ light: MTLight, options: MTStyleSetterOptions?) async {
        await runCommand(SetLight(light: light, options: options))
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
        await runCommand(SetShouldRenderWorldCopies(shouldRenderWorldCopies: shouldRenderWorldCopies))
    }

    /// Adds a marker to the map.
    /// - Parameters:
    ///    - marker: Marker to be added to the map.
    public func addMarker(_ marker: MTMarker) async {
        await runCommand(AddMarker(marker: marker))
    }

    /// Adds multiple markers to the map.
    ///
    /// Batch adding is preferred way of adding multiple markers to the map.
    /// - Parameters:
    ///    - markers: Markers to be added to the map.
    ///    - withSingleIcon: Optional single image to use for all markers.
    public func addMarkers(_ markers: [MTMarker], withSingleIcon: UIImage?) async {
        await runCommand(AddMarkers(markers: markers, withSingleIcon: withSingleIcon))
    }

    /// Removes a marker from the map.
    /// - Parameters:
    ///    - marker: Marker to be removed from the map.
    public func removeMarker(_ marker: MTMarker) async {
        await runCommand(RemoveMarker(marker: marker))
    }

    /// Removes multiple markers from the map.
    ///
    /// Batch removing is preferred way of removing multiple markers from the map.
    /// - Parameters:
    ///    - markers: Markers to be removed from the map.
    public func removeMarkers(_ markers: [MTMarker]) async {
        await runCommand(RemoveMarkers(markers: markers))
    }

    /// Enables the globe projection visualization.
    public func enableGlobeProjection() async {
        await runCommand(EnableGlobeProjection())
    }

    /// Enables the mercator projection visualization.
    public func enableMercatorProjection() async {
        await runCommand(EnableMercatorProjection())
    }

    /// Enables the 3D terrain visualization.
    /// - Parameters:
    ///    - exaggerationFactor: Factor for volume boosting.
    /// - Note: Default is 1.
    public func enableTerrain(exaggerationFactor: Double = 1.0) async {
        await runCommand(EnableTerrain(exaggerationFactor: exaggerationFactor))
    }

    /// Disables  the 3D terrain visualization.
    public func disableTerrain() async {
        await runCommand(DisableTerrain())
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
        await runCommand(SetVerticalFieldOfView(degrees: degrees))
    }

    package func getId(for referenceStyle: MTMapReferenceStyle) async -> String {
        return await runCommandWithStringReturnValue(GetIdForReferenceStyle(referenceStyle: referenceStyle))
    }

    package func getId(for styleVariant: MTMapStyleVariant) async -> String {
        return await runCommandWithStringReturnValue(GetIdForStyleVariant(styleVariant: styleVariant))
    }

    package func getName(for referenceStyle: MTMapReferenceStyle) async -> String {
        return await runCommandWithStringReturnValue(GetNameForReferenceStyle(referenceStyle: referenceStyle))
    }

    package func getName(for styleVariant: MTMapStyleVariant) async -> String {
        return await runCommandWithStringReturnValue(GetNameForStyleVariant(styleVariant: styleVariant))
    }

    package func addSource(_ source: MTSource) async {
        await runCommand(AddSource(source: source))
    }

    package func removeSource(_ source: MTSource) async {
        await runCommand(RemoveSource(source: source))
    }

    package func addLayer(_ layer: MTLayer) async {
        await runCommand(AddLayer(layer: layer))
    }

    package func removeLayer(_ layer: MTLayer) async {
        await runCommand(RemoveLayer(layer: layer))
    }

    package func setCoordinatesTo(_ marker: MTMarker) async {
        await runCommand(SetCoordinatesToMarker(marker: marker))
    }
}
