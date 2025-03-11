//
//  MTStylable.swift
//  MapTilerSDK
//

import Foundation

/// Defines methods for map styling methods.
@MainActor
public protocol MTStylable {
    func setGlyphs(url: URL, options: MTStyleSetterOptions?) async
    func setLanguage(_ language: MTLanguage) async
    func setLight(_ light: MTLight, options: MTStyleSetterOptions?) async
    func setShouldRenderWorldCopies(_ shouldRenderWorldCopies: Bool) async
    func addMarker(_ marker: MTMarker) async
    func removeMarker(_ marker: MTMarker) async
}
