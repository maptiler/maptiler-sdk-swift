//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMap+MTZoomable.swift
//  MapTilerSDK
//

import UIKit

extension MTMapView: MTZoomable {
    /// Increases the map's zoom level by 1.
    ///  - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func zoomIn(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(ZoomIn(), completion: completionHandler)
    }

    /// Decreases the map's zoom level by 1.
    /// - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func zoomOut(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(ZoomOut(), completion: completionHandler)
    }

    /// Returns the map's current zoom level.
    /// - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getZoom(completionHandler: @escaping (Result<Double, MTError>) -> Void) {
        runCommandWithDoubleReturnValue(GetZoom(), completion: completionHandler)
    }

    /// Sets the map's zoom level.
    ///  - Parameters:
    ///     - zoom: The zoom level to set (0-20).
    ///     - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setZoom(_ zoom: Double, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetZoom(zoom: zoom), completion: completionHandler)
    }

    /// Zooms to the specified zoom level with an animated transition.
    /// - Parameters:
    ///   - zoom: The zoom level to transition to.
    ///   - options: Animation options to use.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func zoomTo(
        _ zoom: Double,
        options: MTAnimationOptions? = nil,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(ZoomTo(zoom: zoom, animationOptions: options), completion: completionHandler)
    }
}

// Concurrency
extension MTMapView {
    /// Increases the map's zoom level by 1.
    public func zoomIn() async {
        await withCheckedContinuation { continuation in
            zoomIn { _ in
                continuation.resume()
            }
        }
    }

    /// Decreases the map's zoom level by 1.
    public func zoomOut() async {
        await withCheckedContinuation { continuation in
            zoomOut { _ in
                continuation.resume()
            }
        }
    }

    /// Returns the map's current zoom level.
    public func getZoom() async -> Double {
        await withCheckedContinuation { continuation in
            getZoom { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: .nan)
                }
            }
        }
    }

    /// Sets the map's zoom level.
    ///  - Parameters:
    ///   - zoom: The zoom level to set (0-20).
    public func setZoom(_ zoom: Double) async {
        await withCheckedContinuation { continuation in
            setZoom(zoom) { _ in
                continuation.resume()
            }
        }
    }

    /// Zooms to the specified zoom level with an animated transition.
    /// - Parameters:
    ///   - zoom: The zoom level to transition to.
    ///   - options: Animation options to use.
    public func zoomTo(_ zoom: Double, options: MTAnimationOptions? = nil) async {
        await withCheckedContinuation { continuation in
            zoomTo(zoom, options: options) { _ in
                continuation.resume()
            }
        }
    }
}
