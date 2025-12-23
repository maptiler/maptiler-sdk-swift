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

    /// The maximum width of the popup in pixels.
    public private(set) var maxWidth: Double?

    /// Boolean value indicating whether the popup uses subpixel positioning.
    public private(set) var isSubpixelPositioningEnabled: Bool = false

    /// Boolean value indicating whether the popup is tracking the pointer.
    public private(set) var isTrackingPointer: Bool = false

    /// Boolean value indicating whether the popup is currently open on the map.
    public private(set) var isOpen: Bool = false

    /// Initializes the popup with the specified position and text.
    /// - Parameters:
    ///    - coordinates: Position of the popup.
    ///    - text: Text content of the popup.
    ///  - offset: The pixel distance from the popup's coordinates.
    ///  - maxWidth: The maximum width of the popup.
    public init(
        coordinates: CLLocationCoordinate2D,
        text: String,
        offset: Double = 0.0,
        maxWidth: Double? = nil
    ) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
        self.text = text
        self.offset = offset
        self.maxWidth = maxWidth
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

    /// Sets coordinates for the popup.
    /// - Parameters:
    ///    - coordinates: Position of the popup.
    ///    - mapView: Map view to apply to.
    ///    - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setLngLat(
        _ coordinates: CLLocationCoordinate2D,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        setCoordinates(coordinates, in: mapView, completionHandler: completionHandler)
    }

    /// Sets the maximum width of the popup in pixels.
    /// - Parameters:
    ///   - maxWidth: Maximum width in pixels.
    ///   - mapView: Map view to apply to.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setMaxWidth(
        _ maxWidth: Double,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        self.maxWidth = maxWidth

        mapView.setMaxWidth(maxWidth, to: self, completionHandler: completionHandler)
    }

    /// Sets the pixel offset distance from the popup's anchor coordinate.
    /// - Parameters:
    ///   - offset: Pixel offset applied on both axes.
    ///   - mapView: Map view to apply to.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setOffset(
        _ offset: Double,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        self.offset = offset

        mapView.setOffset(offset, to: self, completionHandler: completionHandler)
    }

    /// Enables or disables subpixel positioning for the popup.
    /// - Parameters:
    ///   - isEnabled: Boolean indicating whether subpixel positioning is enabled.
    ///   - mapView: Map view to apply to.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setSubpixelPositioning(
        _ isEnabled: Bool,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        isSubpixelPositioningEnabled = isEnabled

        mapView.setSubpixelPositioning(isEnabled, for: self, completionHandler: completionHandler)
    }

    /// Updates the popup text content.
    /// - Parameters:
    ///   - text: Text content of the popup.
    ///   - mapView: Map view to apply to.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setText(
        _ text: String,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        self.text = text

        mapView.setText(text, to: self, completionHandler: completionHandler)
    }

    /// Enables tracking the pointer position for the popup.
    /// - Parameters:
    ///   - mapView: Map view to apply to.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func trackPointer(
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        isTrackingPointer = true

        mapView.trackPointer(for: self, completionHandler: completionHandler)
    }

    /// Opens the popup on the provided map view.
    /// - Parameters:
    ///   - mapView: Map view to add the popup to.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func open(
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        mapView.open(self) { [weak self] result in
            if case .success = result {
                self?.isOpen = true
            }

            completionHandler?(result)
        }
    }

    /// Closes the popup on the provided map view.
    /// - Parameters:
    ///   - mapView: Map view to remove the popup from.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func close(
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        mapView.close(self) { [weak self] result in
            if case .success = result {
                self?.isOpen = false
            }

            completionHandler?(result)
        }
    }
}

// Getters
extension MTTextPopup {
    /// Returns current coordinates of the popup.
    /// - Parameters:
    ///   - mapView: Map view to query.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getCoordinates(
        in mapView: MTMapView,
        completionHandler: ((Result<CLLocationCoordinate2D, MTError>) -> Void)? = nil
    ) {
        mapView.runCommandWithCoordinateReturnValue(GetTextPopupCoordinates(popup: self)) { [weak self] result in
            if case .success(let coordinates) = result {
                self?.coordinates = coordinates
            }

            completionHandler?(result)
        }
    }

    /// Returns a Boolean value indicating whether the popup is currently open.
    /// - Parameters:
    ///   - mapView: Map view to query.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func isOpen(
        in mapView: MTMapView,
        completionHandler: ((Result<Bool, MTError>) -> Void)? = nil
    ) {
        mapView.runCommandWithBoolReturnValue(IsTextPopupOpen(popup: self)) { [weak self] result in
            if case .success(let isOpen) = result {
                self?.isOpen = isOpen
            }

            completionHandler?(result)
        }
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

    /// Sets coordinates for the popup.
    /// - Parameter mapView: Map view to apply to.
    @MainActor
    public func setLngLat(_ coordinates: CLLocationCoordinate2D, in mapView: MTMapView) async {
        await setCoordinates(coordinates, in: mapView)
    }

    /// Sets the maximum width of the popup in pixels.
    /// - Parameter mapView: Map view to apply to.
    @MainActor
    public func setMaxWidth(_ maxWidth: Double, in mapView: MTMapView) async {
        self.maxWidth = maxWidth

        await withCheckedContinuation { continuation in
            setMaxWidth(maxWidth, in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the pixel offset distance from the popup's anchor coordinate.
    /// - Parameter mapView: Map view to apply to.
    @MainActor
    public func setOffset(_ offset: Double, in mapView: MTMapView) async {
        self.offset = offset

        await withCheckedContinuation { continuation in
            setOffset(offset, in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Enables or disables subpixel positioning for the popup.
    /// - Parameter mapView: Map view to apply to.
    @MainActor
    public func setSubpixelPositioning(_ isEnabled: Bool, in mapView: MTMapView) async {
        isSubpixelPositioningEnabled = isEnabled

        await withCheckedContinuation { continuation in
            setSubpixelPositioning(isEnabled, in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Updates the popup text content.
    /// - Parameter mapView: Map view to apply to.
    @MainActor
    public func setText(_ text: String, in mapView: MTMapView) async {
        self.text = text

        await withCheckedContinuation { continuation in
            setText(text, in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Enables tracking the pointer position for the popup.
    /// - Parameter mapView: Map view to apply to.
    @MainActor
    public func trackPointer(in mapView: MTMapView) async {
        isTrackingPointer = true

        await withCheckedContinuation { continuation in
            trackPointer(in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Opens the popup on the provided map view.
    /// - Parameter mapView: Map view to add the popup to.
    @MainActor
    public func open(in mapView: MTMapView) async {
        await withCheckedContinuation { continuation in
            open(in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Closes the popup on the provided map view.
    /// - Parameter mapView: Map view to remove the popup from.
    @MainActor
    public func close(in mapView: MTMapView) async {
        await withCheckedContinuation { continuation in
            close(in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Returns current coordinates of the popup.
    /// - Parameter mapView: Map view to query.
    @MainActor
    public func getCoordinates(in mapView: MTMapView) async -> CLLocationCoordinate2D {
        await withCheckedContinuation { continuation in
            getCoordinates(in: mapView) { [weak self] result in
                switch result {
                case .success(let coordinates):
                    continuation.resume(returning: coordinates)
                case .failure:
                    continuation.resume(returning: self?.coordinates ?? CLLocationCoordinate2D())
                }
            }
        }
    }

    /// Returns a Boolean value indicating whether the popup is currently open.
    /// - Parameter mapView: Map view to query.
    @MainActor
    public func isOpen(in mapView: MTMapView) async -> Bool {
        await withCheckedContinuation { continuation in
            isOpen(in: mapView) { [weak self] result in
                switch result {
                case .success(let isOpen):
                    continuation.resume(returning: isOpen)
                case .failure:
                    continuation.resume(returning: self?.isOpen ?? false)
                }
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
                text: self.text,
                offset: self.offset ?? 0.0,
                maxWidth: self.maxWidth
            )

            await mapView.addTextPopup(popup)
        }
    }
}
