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
        id: String = UUID().uuidString,
        position: MTMapCorner,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        if let url = URL(string: "\(MTConfig.shared.apiURL)resources/logo.svg"),
            let linkURL = URL(string: "https://www.maptiler.com") {
            runCommand(
                AddLogoControl(id: id, name: "MapTilerLogo", url: url, linkURL: linkURL, position: position),
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
        id: String = UUID().uuidString,
        name: String,
        logoURL: URL,
        linkURL: URL,
        position: MTMapCorner,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            AddLogoControl(id: id, name: name, url: logoURL, linkURL: linkURL, position: position),
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
        id: String = UUID().uuidString,
        position: MTMapCorner = .topRight,
        showCompass: Bool = true,
        showZoom: Bool = true,
        visualizePitch: Bool = true,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            AddNavigationControl(
                id: id,
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
        id: String = UUID().uuidString,
        position: MTMapCorner = .topRight,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(AddTerrainControl(id: id, position: position), completion: completionHandler)
    }

    /// Adds the attribution control to the map.
    /// - Parameters:
    ///   - position: The corner position of the control.
    ///   - compact: If true, force a compact attribution that shows on click. If false, force the full attribution
    ///              control. The default is a responsive attribution that collapses when the map is less than 640
    ///              pixels wide.
    ///   - customAttribution: String or strings to show in addition to any other attributions.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addAttributionControl(
        id: String = UUID().uuidString,
        position: MTMapCorner = .bottomRight,
        compact: Bool? = nil,
        customAttribution: [String]? = nil,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            AddAttributionControl(id: id, position: position, compact: compact, customAttribution: customAttribution),
            completion: completionHandler
        )
    }

    /// Adds the attribution control to the map.
    /// - Parameters:
    ///   - position: The corner position of the control.
    ///   - compact: If true, force a compact attribution that shows on click. If false, force the full attribution
    ///              control. The default is a responsive attribution that collapses when the map is less than 640
    ///              pixels wide.
    ///   - customAttribution: String to show in addition to any other attributions.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addAttributionControl(
        id: String = UUID().uuidString,
        position: MTMapCorner = .bottomRight,
        compact: Bool? = nil,
        customAttribution: String? = nil,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let attributions = customAttribution.map { [$0] }
        addAttributionControl(
            id: id,
            position: position,
            compact: compact,
            customAttribution: attributions,
            completionHandler: completionHandler
        )
    }

    /// Adds the scale control to the map.
    /// - Parameters:
    ///   - position: The corner position of the control.
    ///   - maxWidth: The maximum length of the scale control in pixels.
    ///   - unit: Unit of the distance.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addScaleControl(
        id: String = UUID().uuidString,
        position: MTMapCorner = .bottomLeft,
        maxWidth: Int? = nil,
        unit: MTUnit? = nil,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            AddScaleControl(id: id, position: position, maxWidth: maxWidth, unit: unit),
            completion: completionHandler
        )
    }

    /// Checks if a control is added to the map.
    /// - Parameters:
    ///   - id: The id of the control.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func hasControl(
        id: String,
        completionHandler: ((Result<Bool, MTError>) -> Void)? = nil
    ) {
        runCommandWithBoolReturnValue(HasControl(id: id), completion: completionHandler)
    }

    /// Removes a control from the map.
    /// - Parameters:
    ///   - id: The id of the control.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func removeControl(
        id: String,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(RemoveControl(id: id), completion: completionHandler)
    }
}

// Concurrency
extension MTMapView {
    /// Adds Maptiler logo to the map.
    /// - Parameters:
    ///   - name: Unique name of the logo.
    ///   - position: The corner position of the logo.
    public func addMapTilerLogoControl(id: String = UUID().uuidString, position: MTMapCorner) async {
        await withCheckedContinuation { continuation in
            addMapTilerLogoControl(id: id, position: position) { _ in
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
    public func addLogoControl(
        id: String = UUID().uuidString,
        name: String,
        logoURL: URL,
        linkURL: URL,
        position: MTMapCorner
    ) async {
        await withCheckedContinuation { continuation in
            addLogoControl(id: id, name: name, logoURL: logoURL, linkURL: linkURL, position: position) { _ in
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
        id: String = UUID().uuidString,
        position: MTMapCorner = .topRight,
        showCompass: Bool = true,
        showZoom: Bool = true,
        visualizePitch: Bool = true
    ) async {
        await withCheckedContinuation { continuation in
            addNavigationControl(
                id: id,
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
    public func addTerrainControl(id: String = UUID().uuidString, position: MTMapCorner = .topRight) async {
        await withCheckedContinuation { continuation in
            addTerrainControl(id: id, position: position) { _ in
                continuation.resume()
            }
        }
    }

    /// Adds the attribution control to the map.
    /// - Parameters:
    ///   - position: The corner position of the control.
    ///   - compact: If true, force a compact attribution that shows on click. If false, force the full attribution
    ///              control. The default is a responsive attribution that collapses when the map is less than 640
    ///              pixels wide.
    ///   - customAttribution: String or strings to show in addition to any other attributions.
    public func addAttributionControl(
        id: String = UUID().uuidString,
        position: MTMapCorner = .bottomRight,
        compact: Bool? = nil,
        customAttribution: [String]? = nil
    ) async {
        await withCheckedContinuation { continuation in
            addAttributionControl(
                id: id,
                position: position,
                compact: compact,
                customAttribution: customAttribution
            ) { _ in
                continuation.resume()
            }
        }
    }

    /// Adds the attribution control to the map.
    /// - Parameters:
    ///   - position: The corner position of the control.
    ///   - compact: If true, force a compact attribution that shows on click. If false, force the full attribution
    ///              control. The default is a responsive attribution that collapses when the map is less than 640
    ///              pixels wide.
    ///   - customAttribution: String to show in addition to any other attributions.
    public func addAttributionControl(
        id: String = UUID().uuidString,
        position: MTMapCorner = .bottomRight,
        compact: Bool? = nil,
        customAttribution: String? = nil
    ) async {
        await withCheckedContinuation { continuation in
            addAttributionControl(
                id: id,
                position: position,
                compact: compact,
                customAttribution: customAttribution
            ) { _ in
                continuation.resume()
            }
        }
    }

    /// Adds the scale control to the map.
    /// - Parameters:
    ///   - position: The corner position of the control.
    ///   - maxWidth: The maximum length of the scale control in pixels.
    ///   - unit: Unit of the distance.
    public func addScaleControl(
        id: String = UUID().uuidString,
        position: MTMapCorner = .bottomLeft,
        maxWidth: Int? = nil,
        unit: MTUnit? = nil
    ) async {
        await withCheckedContinuation { continuation in
            addScaleControl(
                id: id,
                position: position,
                maxWidth: maxWidth,
                unit: unit
            ) { _ in
                continuation.resume()
            }
        }
    }

    /// Checks if a control is added to the map.
    /// - Parameters:
    ///   - id: The id of the control.
    /// - Returns: True if the control is present.
    public func hasControl(id: String) async -> Result<Bool, MTError> {
        await withCheckedContinuation { continuation in
            hasControl(id: id) { result in
                continuation.resume(returning: result)
            }
        }
    }

    /// Removes a control from the map.
    /// - Parameters:
    ///   - id: The id of the control.
    public func removeControl(id: String) async {
        await withCheckedContinuation { continuation in
            removeControl(id: id) { _ in
                continuation.resume()
            }
        }
    }
}
