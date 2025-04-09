//
//  MTStylable.swift
//  MapTilerSDK
//

import Foundation
import UIKit

/// Defines methods for map styling methods.
@MainActor
public protocol MTStylable {
    func setGlyphs(url: URL, options: MTStyleSetterOptions?) async
    func setLanguage(_ language: MTLanguage) async
    func setLight(_ light: MTLight, options: MTStyleSetterOptions?) async
    func setShouldRenderWorldCopies(_ shouldRenderWorldCopies: Bool) async
    func addMarker(_ marker: MTMarker) async
    func addMarkers(_ markers: [MTMarker], withSingleIcon: UIImage?) async
    func removeMarker(_ marker: MTMarker) async
    func removeMarkers(_ markers: [MTMarker]) async
    func enableGlobeProjection() async
    func enableMercatorProjection() async
    func enableTerrain(exaggerationFactor: Double) async
    func disableTerrain() async
    func setVerticalFieldOfView(degrees: Double) async
    func isSourceLoaded(id: String) async -> Bool
}
