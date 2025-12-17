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

    /// Opacity of the marker.
    public var opacity: Double = 1.0

    /// Opacity applied when the marker is covered by another object.
    public var opacityWhenCovered: Double = 0.2

    /// Boolean indicating whether marker is draggable.
    public var draggable: Bool?

    /// Custom icon to use for marker.
    public var icon: UIImage?

    /// Anchor position of the marker.
    public var anchor: MTAnchor = .center

    /// Offset distance from the marker's anchor, applied on both axes in pixels.
    public var offset: Double = 0.0

    /// Scale factor applied to the marker.
    public var scale: Double = 1.0

    /// Enables subpixel positioning when rendering the marker.
    public var subpixelPositioning: Bool = true

    /// Rotation of the marker in degrees.
    public var rotation: Double = 0.0

    /// Alignment of the marker rotation relative to the map or viewport.
    public var rotationAlignment: MTMarkerRotationAlignment = .auto

    /// Alignment of the marker pitch relative to the map or viewport.
    public var pitchAlignment: MTMarkerPitchAlignment = .auto

    /// Optional attached popup.
    public private(set) var popup: MTTextPopup?

    /// Optional attached custom annotation.
    weak public private(set) var annotationView: MTCustomAnnotationView?

    private var tapThreshold: Double = 30.0

    /// Initializes the marker with the specified position.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
    ///    - anchor: Anchor position for the marker.
    ///    - offset: Pixel offset from the anchor applied on both axes.
    public init(
        coordinates: CLLocationCoordinate2D,
        anchor: MTAnchor = .center,
        offset: Double = 0.0,
        opacity: Double = 1.0,
        opacityWhenCovered: Double = 0.2,
        rotation: Double = 0.0,
        rotationAlignment: MTMarkerRotationAlignment = .auto,
        pitchAlignment: MTMarkerPitchAlignment = .auto,
        scale: Double = 1.0,
        subpixelPositioning: Bool = true
    ) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
        self.anchor = anchor
        self.offset = offset
        self.opacity = opacity
        self.opacityWhenCovered = opacityWhenCovered
        self.rotation = rotation
        self.rotationAlignment = rotationAlignment
        self.pitchAlignment = pitchAlignment
        self.scale = scale
        self.subpixelPositioning = subpixelPositioning
    }

    /// Initializes the marker with the specified position and text popup.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
    ///    - popup: Popup to attach to the marker.
    ///    - anchor: Anchor position for the marker.
    ///    - offset: Pixel offset from the anchor applied on both axes.
    public init(
        coordinates: CLLocationCoordinate2D,
        popup: MTTextPopup?,
        anchor: MTAnchor = .center,
        offset: Double = 0.0,
        opacity: Double = 1.0,
        opacityWhenCovered: Double = 0.2,
        rotation: Double = 0.0,
        rotationAlignment: MTMarkerRotationAlignment = .auto,
        pitchAlignment: MTMarkerPitchAlignment = .auto,
        scale: Double = 1.0,
        subpixelPositioning: Bool = true
    ) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
        self.popup = popup
        self.anchor = anchor
        self.offset = offset
        self.opacity = opacity
        self.opacityWhenCovered = opacityWhenCovered
        self.rotation = rotation
        self.rotationAlignment = rotationAlignment
        self.pitchAlignment = pitchAlignment
        self.scale = scale
        self.subpixelPositioning = subpixelPositioning
    }

    /// Initializes the marker with the specified position, color/icon and behaviour.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
    ///    - color: Color of the marker.
    ///    - icon: Icon for the marker.
    ///    - draggable: Boolean indicating whether the  marker is draggable.
    ///    - anchor: Anchor position for the marker.
    ///    - offset: Pixel offset from the anchor applied on both axes.
    public init(
        coordinates: CLLocationCoordinate2D,
        color: UIColor? = .blue,
        icon: UIImage? = nil,
        draggable: Bool? = false,
        anchor: MTAnchor = .center,
        offset: Double = 0.0,
        opacity: Double = 1.0,
        opacityWhenCovered: Double = 0.2,
        rotation: Double = 0.0,
        rotationAlignment: MTMarkerRotationAlignment = .auto,
        pitchAlignment: MTMarkerPitchAlignment = .auto,
        scale: Double = 1.0,
        subpixelPositioning: Bool = true
    ) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
        self.color = color
        self.icon = icon
        self.draggable = draggable
        self.anchor = anchor
        self.offset = offset
        self.opacity = opacity
        self.opacityWhenCovered = opacityWhenCovered
        self.rotation = rotation
        self.rotationAlignment = rotationAlignment
        self.pitchAlignment = pitchAlignment
        self.scale = scale
        self.subpixelPositioning = subpixelPositioning
    }

    /// Initializes the marker with the specified position, color/icon and popup.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
    ///    - color: Color of the marker.
    ///    - icon: Icon for the marker.
    ///    - draggable: Boolean indicating whether the  marker is draggable.
    ///    - popup: Popup to attach to the marker.
    ///    - anchor: Anchor position for the marker.
    ///    - offset: Pixel offset from the anchor applied on both axes.
    public init(
        coordinates: CLLocationCoordinate2D,
        color: UIColor? = .blue,
        icon: UIImage? = nil,
        draggable: Bool? = false,
        popup: MTTextPopup?,
        anchor: MTAnchor = .center,
        offset: Double = 0.0,
        opacity: Double = 1.0,
        opacityWhenCovered: Double = 0.2,
        rotation: Double = 0.0,
        rotationAlignment: MTMarkerRotationAlignment = .auto,
        pitchAlignment: MTMarkerPitchAlignment = .auto,
        scale: Double = 1.0,
        subpixelPositioning: Bool = true
    ) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
        self.color = color
        self.icon = icon
        self.draggable = draggable
        self.popup = popup
        self.anchor = anchor
        self.offset = offset
        self.opacity = opacity
        self.opacityWhenCovered = opacityWhenCovered
        self.rotation = rotation
        self.rotationAlignment = rotationAlignment
        self.pitchAlignment = pitchAlignment
        self.scale = scale
        self.subpixelPositioning = subpixelPositioning
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

    /// Detaches custom annotation view from the marker.
    public func detachAnnotationView() {
        self.annotationView = nil
    }
}

// Setters
extension MTMarker {
    /// Sets whether the marker is draggable.
    /// - Parameters:
    ///   - draggable: Boolean indicating whether the marker should be draggable.
    ///   - mapView: Map view to apply to.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setDraggable(
        _ draggable: Bool,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        self.draggable = draggable

        mapView.setDraggable(draggable, to: self, completionHandler: completionHandler)
    }

    /// Sets the offset distance from the marker's anchor.
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

    /// Sets the rotation of the marker in degrees.
    /// - Parameters:
    ///   - rotation: Rotation in degrees.
    ///   - mapView: Map view to apply to.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setRotation(
        _ rotation: Double,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        self.rotation = rotation

        mapView.setRotation(rotation, to: self, completionHandler: completionHandler)
    }

    /// Sets the rotation alignment of the marker.
    /// - Parameters:
    ///   - alignment: Rotation alignment relative to map or viewport.
    ///   - mapView: Map view to apply to.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setRotationAlignment(
        _ alignment: MTMarkerRotationAlignment,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        self.rotationAlignment = alignment

        mapView.setRotationAlignment(alignment, to: self, completionHandler: completionHandler)
    }

    /// Toggles the popup bound to the marker.
    /// - Parameters:
    ///   - mapView: Map view to apply to.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func togglePopup(
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        mapView.togglePopup(for: self, completionHandler: completionHandler)
    }
}

// Getters
extension MTMarker {
    /// Returns current coordinates of the marker.
    /// - Parameters:
    ///   - mapView: Map view to query.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getCoordinates(
        in mapView: MTMapView,
        completionHandler: ((Result<CLLocationCoordinate2D, MTError>) -> Void)? = nil
    ) {
        mapView.runCommandWithCoordinateReturnValue(GetMarkerCoordinates(marker: self)) { [weak self] result in
            if case .success(let coordinates) = result {
                self?.coordinates = coordinates
            }

            completionHandler?(result)
        }
    }

    /// Returns the marker's pitch alignment.
    /// - Parameters:
    ///   - mapView: Map view to query.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getPitchAlignment(
        in mapView: MTMapView,
        completionHandler: ((Result<MTMarkerPitchAlignment, MTError>) -> Void)? = nil
    ) {
        mapView.runCommandWithStringReturnValue(GetMarkerPitchAlignment(marker: self)) { [weak self] result in
            switch result {
            case .success(let value):
                if let alignment = MTMarkerPitchAlignment(rawValue: value) {
                    self?.pitchAlignment = alignment
                    completionHandler?(.success(alignment))
                } else {
                    completionHandler?(
                        .failure(
                            MTError.unsupportedReturnType(
                                description: "Expected marker pitch alignment, got \(value)."
                            )
                        )
                    )
                }
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }

    /// Returns the marker's rotation value.
    /// - Parameters:
    ///   - mapView: Map view to query.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getRotation(
        in mapView: MTMapView,
        completionHandler: ((Result<Double, MTError>) -> Void)? = nil
    ) {
        mapView.runCommandWithDoubleReturnValue(GetMarkerRotation(marker: self)) { [weak self] result in
            if case .success(let rotation) = result {
                self?.rotation = rotation
            }

            completionHandler?(result)
        }
    }

    /// Returns the marker's rotation alignment.
    /// - Parameters:
    ///   - mapView: Map view to query.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getRotationAlignment(
        in mapView: MTMapView,
        completionHandler: ((Result<MTMarkerRotationAlignment, MTError>) -> Void)? = nil
    ) {
        mapView.runCommandWithStringReturnValue(GetMarkerRotationAlignment(marker: self)) { [weak self] result in
            switch result {
            case .success(let value):
                if let alignment = MTMarkerRotationAlignment(rawValue: value) {
                    self?.rotationAlignment = alignment
                    completionHandler?(.success(alignment))
                } else {
                    completionHandler?(
                        .failure(
                            MTError.unsupportedReturnType(
                                description: "Expected marker rotation alignment, got \(value)."
                            )
                        )
                    )
                }
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }

    /// Returns the marker's offset value in pixels.
    /// - Parameters:
    ///   - mapView: Map view to query.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getOffset(
        in mapView: MTMapView,
        completionHandler: ((Result<Double, MTError>) -> Void)? = nil
    ) {
        mapView.runCommandWithDoubleReturnValue(GetMarkerOffset(marker: self)) { [weak self] result in
            if case .success(let offset) = result {
                self?.offset = offset
            }

            completionHandler?(result)
        }
    }

    /// Returns whether the marker is draggable.
    /// - Parameters:
    ///   - mapView: Map view to query.
    ///   - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func isDraggable(
        in mapView: MTMapView,
        completionHandler: ((Result<Bool, MTError>) -> Void)? = nil
    ) {
        mapView.runCommandWithBoolReturnValue(IsMarkerDraggable(marker: self)) { [weak self] result in
            if case .success(let draggable) = result {
                self?.draggable = draggable
            }

            completionHandler?(result)
        }
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

    /// Sets whether the marker is draggable.
    /// - Parameters:
    ///   - draggable: Boolean indicating whether the marker should be draggable.
    ///   - mapView: Map view to apply to.
    @MainActor
    public func setDraggable(_ draggable: Bool, in mapView: MTMapView) async {
        self.draggable = draggable

        await withCheckedContinuation { continuation in
            setDraggable(draggable, in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the offset distance from the marker's anchor.
    /// - Parameters:
    ///   - offset: Pixel offset applied on both axes.
    ///   - mapView: Map view to apply to.
    @MainActor
    public func setOffset(_ offset: Double, in mapView: MTMapView) async {
        self.offset = offset

        await withCheckedContinuation { continuation in
            setOffset(offset, in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the rotation of the marker in degrees.
    /// - Parameters:
    ///   - rotation: Rotation in degrees.
    ///   - mapView: Map view to apply to.
    @MainActor
    public func setRotation(_ rotation: Double, in mapView: MTMapView) async {
        self.rotation = rotation

        await withCheckedContinuation { continuation in
            setRotation(rotation, in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the rotation alignment of the marker.
    /// - Parameters:
    ///   - alignment: Rotation alignment relative to map or viewport.
    ///   - mapView: Map view to apply to.
    @MainActor
    public func setRotationAlignment(_ alignment: MTMarkerRotationAlignment, in mapView: MTMapView) async {
        self.rotationAlignment = alignment

        await withCheckedContinuation { continuation in
            setRotationAlignment(alignment, in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Toggles the popup bound to the marker.
    /// - Parameter mapView: Map view to apply to.
    @MainActor
    public func togglePopup(in mapView: MTMapView) async {
        await withCheckedContinuation { continuation in
            togglePopup(in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Returns current coordinates of the marker.
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

    /// Returns the marker's pitch alignment.
    /// - Parameter mapView: Map view to query.
    @MainActor
    public func getPitchAlignment(in mapView: MTMapView) async -> MTMarkerPitchAlignment {
        await withCheckedContinuation { continuation in
            getPitchAlignment(in: mapView) { [weak self] result in
                switch result {
                case .success(let alignment):
                    continuation.resume(returning: alignment)
                case .failure:
                    continuation.resume(returning: self?.pitchAlignment ?? .auto)
                }
            }
        }
    }

    /// Returns the marker's rotation value.
    /// - Parameter mapView: Map view to query.
    @MainActor
    public func getRotation(in mapView: MTMapView) async -> Double {
        await withCheckedContinuation { continuation in
            getRotation(in: mapView) { [weak self] result in
                switch result {
                case .success(let rotation):
                    continuation.resume(returning: rotation)
                case .failure:
                    continuation.resume(returning: self?.rotation ?? .nan)
                }
            }
        }
    }

    /// Returns the marker's rotation alignment.
    /// - Parameter mapView: Map view to query.
    @MainActor
    public func getRotationAlignment(in mapView: MTMapView) async -> MTMarkerRotationAlignment {
        await withCheckedContinuation { continuation in
            getRotationAlignment(in: mapView) { [weak self] result in
                switch result {
                case .success(let alignment):
                    continuation.resume(returning: alignment)
                case .failure:
                    continuation.resume(returning: self?.rotationAlignment ?? .auto)
                }
            }
        }
    }

    /// Returns the marker's offset value in pixels.
    /// - Parameter mapView: Map view to query.
    @MainActor
    public func getOffset(in mapView: MTMapView) async -> Double {
        await withCheckedContinuation { continuation in
            getOffset(in: mapView) { [weak self] result in
                switch result {
                case .success(let offset):
                    continuation.resume(returning: offset)
                case .failure:
                    continuation.resume(returning: self?.offset ?? .nan)
                }
            }
        }
    }

    /// Returns whether the marker is draggable.
    /// - Parameter mapView: Map view to query.
    @MainActor
    public func isDraggable(in mapView: MTMapView) async -> Bool {
        await withCheckedContinuation { continuation in
            isDraggable(in: mapView) { [weak self] result in
                switch result {
                case .success(let draggable):
                    continuation.resume(returning: draggable)
                case .failure:
                    continuation.resume(returning: self?.draggable ?? false)
                }
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
                draggable: self.draggable,
                anchor: self.anchor,
                offset: self.offset,
                opacity: self.opacity,
                opacityWhenCovered: self.opacityWhenCovered,
                rotation: self.rotation,
                rotationAlignment: self.rotationAlignment,
                pitchAlignment: self.pitchAlignment,
                scale: self.scale,
                subpixelPositioning: self.subpixelPositioning
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
