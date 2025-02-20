//
//  MTControllable.swift
//  MapTilerSDK
//

import Foundation

/// Defines methods for adding the map controls.
@MainActor
public protocol MTControllable {
    func addMapTilerLogoControl(position: MTMapCorner) async
    func addLogoControl(logoURL: URL, linkURL: URL, position: MTMapCorner) async
}
