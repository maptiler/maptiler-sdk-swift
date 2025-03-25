//
//  MTMapView+MTControllable.swift
//  MapTilerSDK
//

import Foundation

extension MTMapView: MTControllable {
    /// Adds Maptiler logo to the map.
    /// - Parameters:
    ///   - position: The corner position of the logo.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addMapTilerLogoControl(
        position: MTMapCorner,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        if let url = URL(string: "https://api.maptiler.com/resources/logo.svg"),
            let linkURL = URL(string: "https://www.maptiler.com") {
            runCommand(AddLogoControl(url: url, linkURL: linkURL, position: position), completion: completionHandler)
        }
    }

    /// Adds logo control to the map.
    /// - Parameters:
    ///    - logoURL: URL of logo image.
    ///    - linkURL: URL of logo link.
    ///   - position: The corner position of the logo.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addLogoControl(
        logoURL: URL,
        linkURL: URL,
        position: MTMapCorner,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(AddLogoControl(url: logoURL, linkURL: linkURL, position: position), completion: completionHandler)
    }
}

// Concurrency
extension MTMapView {
    /// Adds Maptiler logo to the map.
    /// - Parameters:
    ///   - position: The corner position of the logo.
    public func addMapTilerLogoControl(position: MTMapCorner) async {
        await withCheckedContinuation { continuation in
            addMapTilerLogoControl(position: position) { _ in
                continuation.resume()
            }
        }
    }

    /// Adds logo control to the map.
    /// - Parameters:
    ///    - logoURL: URL of logo image.
    ///    - linkURL: URL of logo link.
    ///   - position: The corner position of the logo.
    public func addLogoControl(logoURL: URL, linkURL: URL, position: MTMapCorner) async {
        await withCheckedContinuation { continuation in
            addLogoControl(logoURL: logoURL, linkURL: linkURL, position: position) { _ in
                continuation.resume()
            }
        }
    }
}
