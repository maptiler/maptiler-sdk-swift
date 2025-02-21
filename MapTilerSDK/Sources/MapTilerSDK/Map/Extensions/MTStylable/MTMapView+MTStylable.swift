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
        await bridge.execute(SetGlyphs(url: url, options: options))
    }

    /// Sets the map labels language.
    ///
    /// The language generally depends on the style. Whenever a label is not supported in the defined language,
    /// it falls back to MTLanguage.latin.
    /// - Parameters:
    ///   - language: The language to be applied.
    public func setLanguage(_ language: MTLanguage) async {
        await bridge.execute(SetLanguage(language: language))
    }

    /// Sets the any combination of light values.
    /// - Parameters:
    ///   - light: Light properties to set.
    ///   - options: Supporting type to add validation to another style related type.
    public func setLight(_ light: MTLight, options: MTStyleSetterOptions?) async {
        await bridge.execute(SetLight(light: light, options: options))
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
        await bridge.execute(SetShouldRenderWorldCopies(shouldRenderWorldCopies: shouldRenderWorldCopies))
    }

    /// Updates the map's style object with a new value.
    ///   - Parameters:
    ///     - referenceStyle:  Desired reference map style.
    ///     - styleVariant: Optional variant of the reference style.
    public func setStyle(_ referenceStyle: MTMapReferenceStyle, styleVariant: MTMapStyleVariant?) async {
        await bridge.execute(SetStyle(referenceStyle: referenceStyle, styleVariant: styleVariant))
    }
}
