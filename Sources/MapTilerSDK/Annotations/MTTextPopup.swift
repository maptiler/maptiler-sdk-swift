//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTextPopup.swift
//  MapTilerSDK
//

import CoreLocation

/// Basic text popup.
///
/// Can be attached to MTMarker or standalone.
public class MTTextPopup: MTAnnotation, MTMapViewContent, @unchecked Sendable {
    /// Unique id of the popup.
    public private(set) var identifier: String

    /// Position of the popup on the map.
    public private(set) var coordinates: CLLocationCoordinate2D

    /// Text content of the popup.
    public private(set) var text: String

    /// The pixel distance from the popup's coordinates.
    public private(set) var offset: Double? = 0.0

    /// Initializes the popup with the specified position and text.
    /// - Parameters:
    ///    - coordinates: Position of the popup.
    ///    - text: Text content of the popup.
    ///  - offset: The pixel distance from the popup's coordinates.
    public init(
        coordinates: CLLocationCoordinate2D,
        text: String,
        offset: Double = 0.0
    ) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
        self.text = text
        self.offset = offset
    }

    /// Sets coordinates for the popup.
    /// - Parameters:
    ///    - coordinates: Position of the popup
    ///    - mapView: Map view to apply to.
    ///    - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setCoordinates(
        _ coordinates: CLLocationCoordinate2D,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        self.coordinates = coordinates

        mapView.setCoordinatesTo(self, completionHandler: completionHandler)
    }
}

// Concurrency
extension MTTextPopup {
    /// Sets coordinates for the popup.
    /// - Parameters:
    ///    - coordinates: Position of the popup.
    ///    - mapView: Map view to apply to.
    @MainActor
    public func setCoordinates(_ coordinates: CLLocationCoordinate2D, in mapView: MTMapView) async {
        self.coordinates = coordinates

        await withCheckedContinuation { continuation in
            setCoordinates(coordinates, in: mapView) { _ in
                continuation.resume()
            }
        }
    }
}

// DSL
extension MTTextPopup {
    /// Adds popup to map DSL style.
    ///
    /// Prefer ``MTMapView/addTextPopup(_:)`` instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let popup = MTTextPopup(
                coordinates: self.coordinates,
                text: self.text
            )

            await mapView.addTextPopup(popup)
        }
    }
}
