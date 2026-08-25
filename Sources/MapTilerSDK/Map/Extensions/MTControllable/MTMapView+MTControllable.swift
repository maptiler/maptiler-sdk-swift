//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
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

    /// Adds navigation control to the map.
    /// - Parameters:
    ///   - position: The corner position of the control.
    ///   - showCompass: If true the compass button is included.
    ///   - showZoom: If true the zoom-in and zoom-out buttons are included.
    ///   - visualizePitch: If true the pitch is visualized by rotating X-axis of compass.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addNavigationControl(
        position: MTMapCorner = .topRight,
        showCompass: Bool = true,
        showZoom: Bool = true,
        visualizePitch: Bool = true,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            AddNavigationControl(
                position: position,
                showCompass: showCompass,
                showZoom: showZoom,
                visualizePitch: visualizePitch
            ),
            completion: completionHandler
        )
    }

    /// Toggles the compass visibility on the navigation control.
    /// - Parameters:
    ///   - showCompass: If true the compass button is included.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func navigationControlShowCompass(
        _ showCompass: Bool,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(NavigationControlShowCompass(showCompass: showCompass), completion: completionHandler)
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

    /// Adds navigation control to the map.
    /// - Parameters:
    ///   - position: The corner position of the control.
    ///   - showCompass: If true the compass button is included.
    ///   - showZoom: If true the zoom-in and zoom-out buttons are included.
    ///   - visualizePitch: If true the pitch is visualized by rotating X-axis of compass.
    public func addNavigationControl(
        position: MTMapCorner = .topRight,
        showCompass: Bool = true,
        showZoom: Bool = true,
        visualizePitch: Bool = true
    ) async {
        await withCheckedContinuation { continuation in
            addNavigationControl(
                position: position,
                showCompass: showCompass,
                showZoom: showZoom,
                visualizePitch: visualizePitch
            ) { _ in
                continuation.resume()
            }
        }
    }

    /// Toggles the compass visibility on the navigation control.
    /// - Parameters:
    ///   - showCompass: If true the compass button is included.
    public func navigationControlShowCompass(_ showCompass: Bool) async {
        await withCheckedContinuation { continuation in
            navigationControlShowCompass(showCompass) { _ in
                continuation.resume()
            }
        }
    }
}
