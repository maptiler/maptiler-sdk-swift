//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTImageSource.swift
//  MapTilerSDK
//

import Foundation

/// An image source.
///
/// The `url` value contains the image location.
/// The `coordinates` array contains [longitude, latitude] pairs for the image corners
/// listed in clockwise order: top left, top right, bottom right, bottom left.
public class MTImageSource: MTSource, @unchecked Sendable {
    /// Unique id of the source.
    public var identifier: String

    /// URL that points to an image.
    public var url: URL?

    /// Corners of image specified in longitude, latitude pairs.
    /// Clockwise order: top-left, top-right, bottom-right, bottom-left.
    public var coordinates: [[Double]]

    /// Type of the source.
    public private(set) var type: MTSourceType = .image

    /// Initializes the image source with required values.
    /// - Parameters:
    ///   - identifier: Unique id of the source.
    ///   - url: URL to the image resource.
    ///   - coordinates: Corners of image in [lng, lat] clockwise order.
    public init(identifier: String, url: URL, coordinates: [[Double]]) {
        self.identifier = identifier
        self.url = url
        self.coordinates = coordinates
    }
}

// MARK: - Operations
extension MTImageSource {
    /// Updates the coordinates of the image source.
    /// - Parameters:
    ///   - coordinates: New corners of the image specified in [lng, lat] pairs.
    ///   - mapView: MTMapView which holds the source.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setCoordinates(
        _ coordinates: [[Double]],
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        mapView.setCoordinates(coordinates, to: self, completionHandler: completionHandler)
    }

    /// Updates the image URL and coordinates simultaneously.
    /// - Parameters:
    ///   - url: New image URL.
    ///   - coordinates: New corners of the image specified in [lng, lat] pairs.
    ///   - mapView: MTMapView which holds the source.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func updateImage(
        url: URL,
        coordinates: [[Double]],
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        mapView.updateImage(url: url, coordinates: coordinates, to: self, completionHandler: completionHandler)
    }
}

// MARK: - Concurrency
extension MTImageSource {
    /// Updates the coordinates of the image source.
    /// - Parameters:
    ///   - coordinates: New corners of the image specified in [lng, lat] pairs.
    ///   - mapView: MTMapView which holds the source.
    @MainActor
    public func setCoordinates(_ coordinates: [[Double]], in mapView: MTMapView) async {
        await withCheckedContinuation { continuation in
            setCoordinates(coordinates, in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Updates the image URL and coordinates simultaneously.
    /// - Parameters:
    ///   - url: New image URL.
    ///   - coordinates: New corners of the image specified in [lng, lat] pairs.
    ///   - mapView: MTMapView which holds the source.
    @MainActor
    public func updateImage(url: URL, coordinates: [[Double]], in mapView: MTMapView) async {
        await withCheckedContinuation { continuation in
            updateImage(url: url, coordinates: coordinates, in: mapView) { _ in
                continuation.resume()
            }
        }
    }
}

// MARK: - DSL
extension MTImageSource {
    /// Adds source to map DSL style.
    ///
    /// Prefer ``MTStyle/addSource(_:)`` on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            guard let url = self.url else { return }
            let source = MTImageSource(
                identifier: self.identifier,
                url: url,
                coordinates: self.coordinates
            )

            try await mapView.style?.addSource(source)
        }
    }
}
