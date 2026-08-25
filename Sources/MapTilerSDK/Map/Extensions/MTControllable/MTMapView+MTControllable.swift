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

    /// Toggles the zoom controls visibility on the navigation control.
    /// - Parameters:
    ///   - showZoom: If true the zoom-in and zoom-out buttons are included.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func navigationControlShowZoom(
        _ showZoom: Bool,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(NavigationControlShowZoom(showZoom: showZoom), completion: completionHandler)
    }

    /// Toggles the pitch visualization on the navigation control compass.
    /// - Parameters:
    ///   - visualizePitch: If true the pitch is visualized by rotating X-axis of compass.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func navigationControlVisualizePitch(
        _ visualizePitch: Bool,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(NavigationControlVisualizePitch(visualizePitch: visualizePitch), completion: completionHandler)
    }

    /// Adds the terrain control to the map.
    /// - Parameters:
    ///   - position: The corner position of the control.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addTerrainControl(
        position: MTMapCorner = .topRight,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(AddTerrainControl(position: position), completion: completionHandler)
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

    /// Toggles the zoom controls visibility on the navigation control.
    /// - Parameters:
    ///   - showZoom: If true the zoom-in and zoom-out buttons are included.
    public func navigationControlShowZoom(_ showZoom: Bool) async {
        await withCheckedContinuation { continuation in
            navigationControlShowZoom(showZoom) { _ in
                continuation.resume()
            }
        }
    }

    /// Toggles the pitch visualization on the navigation control compass.
    /// - Parameters:
    ///   - visualizePitch: If true the pitch is visualized by rotating X-axis of compass.
    public func navigationControlVisualizePitch(_ visualizePitch: Bool) async {
        await withCheckedContinuation { continuation in
            navigationControlVisualizePitch(visualizePitch) { _ in
                continuation.resume()
            }
        }
    }

    /// Adds the terrain control to the map.
    /// - Parameters:
    ///   - position: The corner position of the control.
    public func addTerrainControl(position: MTMapCorner = .topRight) async {
        await withCheckedContinuation { continuation in
            addTerrainControl(position: position) { _ in
                continuation.resume()
            }
        }
    }
}
