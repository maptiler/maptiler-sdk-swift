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
        return await runCommand(AddSource(source: source))
    }

    package func removeSource(_ source: MTSource) async {
        return await runCommand(RemoveSource(source: source))
    }
}
