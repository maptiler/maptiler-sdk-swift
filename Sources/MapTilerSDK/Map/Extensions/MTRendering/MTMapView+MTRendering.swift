//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapView+MTRendering.swift
//  MapTilerSDK
//

extension MTMapView: MTRendering {
    /// Returns the pixel ratio currently used by the map.
    /// - Parameter completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getPixelRatio(completionHandler: @escaping (Result<Double, MTError>) -> Void) {
        runCommandWithDoubleReturnValue(GetPixelRatio(), completion: completionHandler)
    }

    /// Sets the pixel ratio used by the map.
    /// - Parameters:
    ///   - pixelRatio: Pixel ratio value to apply.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setPixelRatio(
        _ pixelRatio: Double,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetPixelRatio(pixelRatio: pixelRatio), completion: completionHandler)

        options?.setPixelRatio(pixelRatio)
    }

    /// Trigger the rendering of a single frame. Use this method with custom layers to repaint the map
    /// when the layer changes. Calling this multiple times before the next frame is rendered will still
    /// result in only a single frame being rendered.
    /// - Parameter completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func triggerRepaint(
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(TriggerRepaint(), completion: completionHandler)
    }

    /// Displays tile boundaries on the map.
    /// - Parameters:
    ///   - show: A boolean value indicating whether to show tile boundaries.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setShowTileBoundaries(
        _ show: Bool,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetShowTileBoundaries(show: show), completion: completionHandler)
    }

    /// Displays padding on the map.
    /// - Parameters:
    ///   - show: A boolean value indicating whether to show padding.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setShowPadding(
        _ show: Bool,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetShowPadding(show: show), completion: completionHandler)
    }

    /// Displays the overdraw inspector on the map.
    /// - Parameters:
    ///   - show: A boolean value indicating whether to show the overdraw inspector.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setShowOverdrawInspector(
        _ show: Bool,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetShowOverdrawInspector(show: show), completion: completionHandler)
    }

    /// Displays collision boxes on the map.
    /// - Parameters:
    ///   - show: A boolean value indicating whether to show collision boxes.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setShowCollisionBoxes(
        _ show: Bool,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetShowCollisionBoxes(show: show), completion: completionHandler)
    }
}

// Concurrency
extension MTMapView {
    /// Returns the pixel ratio currently used by the map.
    public func getPixelRatio() async -> Double {
        await withCheckedContinuation { continuation in
            getPixelRatio { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: .nan)
                }
            }
        }
    }

    /// Sets the pixel ratio used by the map.
    /// - Parameter pixelRatio: Pixel ratio value to apply.
    public func setPixelRatio(_ pixelRatio: Double) async {
        await withCheckedContinuation { continuation in
            setPixelRatio(pixelRatio) { _ in
                continuation.resume()
            }
        }
    }

    /// Trigger the rendering of a single frame. Use this method with custom layers to repaint the map
    /// when the layer changes. Calling this multiple times before the next frame is rendered will still
    /// result in only a single frame being rendered.
    public func triggerRepaint() async {
        await withCheckedContinuation { continuation in
            triggerRepaint { _ in
                continuation.resume()
            }
        }
    }

    /// Displays tile boundaries on the map.
    /// - Parameter show: A boolean value indicating whether to show tile boundaries.
    public func setShowTileBoundaries(_ show: Bool) async {
        await withCheckedContinuation { continuation in
            setShowTileBoundaries(show) { _ in
                continuation.resume()
            }
        }
    }

    /// Displays padding on the map.
    /// - Parameter show: A boolean value indicating whether to show padding.
    public func setShowPadding(_ show: Bool) async {
        await withCheckedContinuation { continuation in
            setShowPadding(show) { _ in
                continuation.resume()
            }
        }
    }

    /// Displays the overdraw inspector on the map.
    /// - Parameter show: A boolean value indicating whether to show the overdraw inspector.
    public func setShowOverdrawInspector(_ show: Bool) async {
        await withCheckedContinuation { continuation in
            setShowOverdrawInspector(show) { _ in
                continuation.resume()
            }
        }
    }

    /// Displays collision boxes on the map.
    /// - Parameter show: A boolean value indicating whether to show collision boxes.
    public func setShowCollisionBoxes(_ show: Bool) async {
        await withCheckedContinuation { continuation in
            setShowCollisionBoxes(show) { _ in
                continuation.resume()
            }
        }
    }
}
