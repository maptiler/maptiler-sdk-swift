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
            runCommand(
                AddLogoControl(name: "MapTilerLogo", url: url, linkURL: linkURL, position: position),
                completion: completionHandler
            )

            options?.setLogoPosition(position)
        }
    }

    /// Adds logo control to the map.
    /// - Parameters:
    ///    - name: Unique name of the logo.
    ///    - logoURL: URL of logo image.
    ///    - linkURL: URL of logo link.
    ///   - position: The corner position of the logo.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addLogoControl(
        name: String,
        logoURL: URL,
        linkURL: URL,
        position: MTMapCorner,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            AddLogoControl(name: name, url: logoURL, linkURL: linkURL, position: position),
            completion: completionHandler
        )

        options?.setLogoPosition(position)
    }
}

// Concurrency
extension MTMapView {
    /// Adds Maptiler logo to the map.
    /// - Parameters:
    ///   - name: Unique name of the logo.
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
    ///    - name: Unique name of the logo.
    ///    - logoURL: URL of logo image.
    ///    - linkURL: URL of logo link.
    ///   - position: The corner position of the logo.
    public func addLogoControl(name: String, logoURL: URL, linkURL: URL, position: MTMapCorner) async {
        await withCheckedContinuation { continuation in
            addLogoControl(name: name, logoURL: logoURL, linkURL: linkURL, position: position) { _ in
                continuation.resume()
            }
        }
    }
}
