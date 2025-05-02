//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMarker.swift
//  MapTilerSDK
//

import UIKit
import CoreLocation

/// Annotation element that can be added to the map.
public class MTMarker: MTAnnotation, MTMapViewContent, @unchecked Sendable {
    /// Unique id of the marker.
    public private(set) var identifier: String

    /// Position of the marker on the map.
    public private(set) var coordinates: CLLocationCoordinate2D

    /// Color of the marker.
    public var color: UIColor?

    /// Boolean indicating whether marker is draggable.
    public var draggable: Bool?

    /// Custom icon to use for marker.
    public var icon: UIImage?

    /// Optional attached popup.
    public private(set) var popup: MTTextPopup?

    /// Optional attached custom annotation.
    weak public private(set) var annotationView: MTCustomAnnotationView?

    private var tapThreshold: Double = 30.0

    /// Initializes the marker with the specified position.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
    public init(coordinates: CLLocationCoordinate2D) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
    }

    /// Initializes the marker with the specified position and text popup.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
    ///    - popup: Popup to attach to the marker.
    public init(coordinates: CLLocationCoordinate2D, popup: MTTextPopup?) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
        self.popup = popup
    }

    /// Initializes the marker with the specified position, color/icon and behaviour.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
    ///    - color: Color of the marker.
    ///    - icon: Icon for the marker.
    ///    - draggable: Boolean indicating whether the  marker is draggable.
    public init(
        coordinates: CLLocationCoordinate2D,
        color: UIColor? = .blue,
        icon: UIImage? = nil,
        draggable: Bool? = false
    ) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
        self.color = color
        self.icon = icon
        self.draggable = draggable
    }

    /// Initializes the marker with the specified position, color/icon and popup.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
    ///    - color: Color of the marker.
    ///    - icon: Icon for the marker.
    ///    - draggable: Boolean indicating whether the  marker is draggable.
    ///    - popup: Popup to attach to the marker.
    public init(
        coordinates: CLLocationCoordinate2D,
        color: UIColor? = .blue,
        icon: UIImage? = nil,
        draggable: Bool? = false,
        popup: MTTextPopup?
    ) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
        self.color = color
        self.icon = icon
        self.draggable = draggable
        self.popup = popup
    }

    /// Sets coordinates for the marker.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
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

    /// Sets marker as map's delegate.
    /// - Parameters:
    ///    - mapView: Map view for which to subscribe to.
    @MainActor
    public func setDelegate(to mapView: MTMapView) {
        mapView.addContentDelegate(self)
    }

    /// Attaches custom annotation view to the marker.
    ///
    /// - Note: Does not add the custom view to the map. Use customAnnotationView.addTo.
    public func attachAnnotationView(_ view: MTCustomAnnotationView) {
        self.annotationView = view
    }
}

// Concurrency
extension MTMarker {
    /// Sets coordinates for the marker.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
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
extension MTMarker {
    /// Adds marker to map DSL style.
    ///
    /// Prefer ``MTMapView/addMarker(_:)`` instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let marker = MTMarker(
                coordinates: self.coordinates,
                color: self.color,
                icon: self.icon,
                draggable: self.draggable
            )

            marker.popup = self.popup

            await mapView.addMarker(marker)
        }
    }

    /// Modifier. Sets the ``popup``.
    /// - Note: Not to be used outside of DSL.
    @discardableResult
    public func popup(_ value: MTTextPopup) -> Self {
        self.popup = value

        return self
    }
}

extension MTMarker: MTMapViewContentDelegate {
    package func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?) {
        if event == .isDragging {
            if let data = data, let coordinates = data.coordinate {
                self.coordinates = coordinates
                annotationView?.setCoordinates(self.coordinates, in: mapView)
            }
        } else if event == .didTap {
            if let tapCoordinate = data?.coordinate {
                Task {
                    let tapPoint = await mapView.project(coordinates: tapCoordinate)
                    let markerPoint = await mapView.project(coordinates: self.coordinates)

                    let dx = tapPoint.x - markerPoint.x
                    let dy = tapPoint.y - markerPoint.y
                    let distance = sqrt(dx * dx + dy * dy)

                    if distance < tapThreshold {
                        await annotationView?.addTo(mapView)
                    }
                }
            }
        }
    }
}
