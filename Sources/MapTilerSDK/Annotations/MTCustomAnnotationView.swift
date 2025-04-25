//
//  MTCustomAnnotationView.swift
//  MapTilerSDK
//

import UIKit
import CoreLocation

/// Subclassable view for adding custom annotations to the map.
@MainActor
open class MTCustomAnnotationView: UIView, @preconcurrency MTAnnotation {
    /// Unique id of the view.
    public private(set) var identifier: String

    /// Position of the view on the map.
    public private(set) var coordinates: CLLocationCoordinate2D

    /// Offset from the center.
    public private(set) var offset: MTPoint = MTPoint(x: 0.0, y: 0.0)

    // Initializes the view with the specified position.
    /// - Parameters:
    ///    - frame: Frame of the annotation view.
    ///    - coordinates: Position of the annotation.
    public init(
        frame: CGRect,
        coordinates: CLLocationCoordinate2D
    ) {
        self.identifier = "annot\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates

        super.init(frame: frame)
    }

    // Initializes the view with the specified position and offset.
    /// - Parameters:
    ///    - frame: Frame of the annotation view.
    ///    - coordinates: Position of the annotation.
    ///    - offset: Offset from the center.
    public init(
        frame: CGRect,
        coordinates: CLLocationCoordinate2D,
        offset: MTPoint
    ) {
        self.identifier = "annot\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
        self.offset = offset

        super.init(frame: frame)
    }

    /// Initializes the view with the frame and centered coordinates.
    /// - Parameters:
    ///    - frame: Frame of the annotation view.
    public override init(frame: CGRect) {
        self.identifier = "annot\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)

        super.init(frame: frame)
    }

    /// Not implemented code init.
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets the offset of the annotation view in pixels.
    /// - Parameters:
    ///    - offset: Desired offset.
    public func setOffset(_ offset: MTPoint) {
        self.offset = offset
    }

    /// Sets coordinates for the view.
    /// - Parameters:
    ///    - coordinates: Position of the view
    ///    - completionHandler: A handler block to execute when function finishes.
    ///    - mapView: Map view to apply to.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setCoordinates(
        _ coordinates: CLLocationCoordinate2D,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        self.coordinates = coordinates

        mapView.project(coordinates: coordinates) { [weak self] result in
            switch result {
            case .success(let point):
                self?.center = CGPoint(
                    x: point.latitude + (self?.offset.x ?? 0.0),
                    y: point.longitude + (self?.offset.y ?? 0.0)
                )
                completionHandler?(.success(()))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }

    /// Adds custom annotation view to the map.
    /// - Parameters:
    ///    - mapView: Map view to add annotation to.
    ///    - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addTo(_ mapView: MTMapView, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        mapView.addContentDelegate(self)

        mapView.project(coordinates: coordinates) { result in
            switch result {
            case .success(let point):
                self.center = CGPoint(x: point.latitude + self.offset.x, y: point.longitude + self.offset.y)

                mapView.addSubview(self)
                mapView.bringSubviewToFront(self)

                completionHandler?(.success(()))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }

    /// Removes custom annotation view from the map.
    public func remove() {
        removeFromSuperview()
    }

    private func mercatorX(from lon: Double) -> Double {
        return (lon + 180.0) / 360.0
    }

    private func mercatorY(from lat: Double) -> Double {
        let latRad = lat * .pi / 180.0
        return (1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / .pi) / 2.0
    }

    // swiftlint:disable all
    @available(iOS, deprecated: 16.0, message: "Prefer project method.")
    private func convertLatLonToCGPoint(
        lat: Double,
        lon: Double,
        mapCenterLat: Double,
        mapCenterLon: Double,
        zoomLevel: Double,
        mapWidth: Double,
        mapHeight: Double
    ) -> CGPoint {

        // Full map size at this zoom level.
        let scale = pow(2.0, zoomLevel) * 512.0

        let pointX = mercatorX(from: lon)
        let pointY = mercatorY(from: lat)

        let centerX = mercatorX(from: mapCenterLon)
        let centerY = mercatorY(from: mapCenterLat)

        let worldX = pointX * scale
        let worldY = pointY * scale
        let centerWorldX = centerX * scale
        let centerWorldY = centerY * scale

        let screenX = worldX - centerWorldX + mapWidth / 2.0
        let screenY = worldY - centerWorldY + mapHeight / 2.0

        return CGPoint(x: screenX, y: screenY)
    }
    // swiftlint:enable all
}

// Concurrency
extension MTCustomAnnotationView {
    /// Sets coordinates for the view.
    /// - Parameters:
    ///    - coordinates: Position of the view.
    @MainActor
    public func setCoordinates(_ coordinates: CLLocationCoordinate2D, in mapView: MTMapView) async {
        self.coordinates = coordinates

        await withCheckedContinuation { continuation in
            setCoordinates(coordinates, in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Adds custom annotation view to the map.
    /// - Parameters:
    ///    - mapView: Map view to add annotation to.
    public func addTo(_ mapView: MTMapView) async {
        await withCheckedContinuation { continuation in
            addTo(mapView) { _ in
                continuation.resume()
            }
        }
    }
}

// DSL
extension MTCustomAnnotationView: @preconcurrency MTMapViewContent {
    /// Adds annotation view to map DSL style.
    ///
    /// Prefer ``addTo(_:)`` instead.
    @MainActor
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let annotation = MTCustomAnnotationView(frame: self.frame, coordinates: self.coordinates)

            await annotation.addTo(mapView)
        }
    }
}

extension MTCustomAnnotationView: MTMapViewContentDelegate {
    package func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?) {
        if event == .isMoving {
            Task {
                await self.setCoordinates(self.coordinates, in: mapView)
            }
        }
    }
}
