//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTVideoSource.swift
//  MapTilerSDK
//

import Foundation
import CoreLocation

/// A video source.
///
/// The `urls` value is an array. For each URL in the array, a video element source will be created.
/// The `coordinates` array contains [longitude, latitude] pairs for the video corners listed in
/// clockwise order: top left, top right, bottom right, bottom left.
public class MTVideoSource: MTSource, @unchecked Sendable {
    /// Unique id of the source.
    public var identifier: String

    /// Unused for video sources but required by `MTSource` protocol.
    /// First URL from `urls` may be mirrored here if needed by callers.
    public var url: URL?

    /// URLs to video content in order of preferred format.
    public var urls: [URL]

    /// Corners of video specified as `CLLocationCoordinate2D`.
    /// Clockwise order: top-left, top-right, bottom-right, bottom-left.
    public var coordinates: [CLLocationCoordinate2D]

    /// Type of the source.
    public private(set) var type: MTSourceType = .video

    /// Initializes the video source with required values.
    /// - Parameters:
    ///   - identifier: Unique id of the source.
    ///   - urls: URLs to video content in order of preferred format.
    ///   - coordinates: Corners of the video in clockwise order using `CLLocationCoordinate2D`.
    public init(identifier: String, urls: [URL], coordinates: [CLLocationCoordinate2D]) {
        self.identifier = identifier
        self.urls = urls
        self.coordinates = coordinates
        self.url = urls.first
    }
}

// MARK: - Operations
extension MTVideoSource {
    /// Updates the coordinates of the video source.
    /// - Parameters:
    ///   - coordinates: New corners of the video using `CLLocationCoordinate2D`.
    ///   - mapView: MTMapView which holds the source.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setCoordinates(
        _ coordinates: [CLLocationCoordinate2D],
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        mapView.setCoordinates(coordinates, to: self, completionHandler: completionHandler)
    }
}

// MARK: - Concurrency
extension MTVideoSource {
    /// Updates the coordinates of the video source.
    /// - Parameters:
    ///   - coordinates: New corners of the video using `CLLocationCoordinate2D`.
    ///   - mapView: MTMapView which holds the source.
    @MainActor
    public func setCoordinates(_ coordinates: [CLLocationCoordinate2D], in mapView: MTMapView) async {
        await withCheckedContinuation { continuation in
            setCoordinates(coordinates, in: mapView) { _ in
                continuation.resume()
            }
        }
    }
}

// MARK: - DSL
extension MTVideoSource {
    /// Adds source to map DSL style.
    ///
    /// Prefer ``MTStyle/addSource(_:)`` on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let source = MTVideoSource(
                identifier: self.identifier,
                urls: self.urls,
                coordinates: self.coordinates
            )

            try await mapView.style?.addSource(source)
        }
    }
}
