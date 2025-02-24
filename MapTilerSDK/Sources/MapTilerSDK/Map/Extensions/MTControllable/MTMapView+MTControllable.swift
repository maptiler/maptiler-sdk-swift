//
//  MTMapView+MTControllable.swift
//  MapTilerSDK
//

import Foundation

extension MTMapView: MTControllable {
    /// Adds Maptiler logo to the map.
    /// - Parameters:
    ///   - position: The corner position of the logo.
    public func addMapTilerLogoControl(position: MTMapCorner) async {
        if let url = URL(string: "https://api.maptiler.com/resources/logo.svg"),
            let linkURL = URL(string: "https://www.maptiler.com") {
            await bridge.execute(AddLogoControl(url: url, linkURL: linkURL, position: position))
        }
    }

    /// Adds logo control to the map.
    /// - Parameters:
    ///    - logoURL: URL of logo image.
    ///    - linkURL: URL of logo link.
    ///   - position: The corner position of the logo.
    public func addLogoControl(logoURL: URL, linkURL: URL, position: MTMapCorner) async {
        await bridge.execute(AddLogoControl(url: logoURL, linkURL: linkURL, position: position))
    }
}
