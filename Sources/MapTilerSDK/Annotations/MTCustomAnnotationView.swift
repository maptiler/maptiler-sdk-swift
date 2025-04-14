//
//  MTCustomAnnotationView.swift
//  MapTilerSDK
//

import UIKit
import CoreLocation

@MainActor
open class MTCustomAnnotationView: UIView, @preconcurrency MTAnnotation, @unchecked Sendable {
    /// Unique id of the view.
    public private(set) var identifier: String

    /// Position of the view on the map.
    public private(set) var coordinates: CLLocationCoordinate2D

    // Initializes the view with the specified position.
    /// - Parameters:
    ///    - coordinates: Position of the annotation.
    public init(
        frame: CGRect,
        coordinates: CLLocationCoordinate2D
    ) {
        self.identifier = "annot\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates

        super.init(frame: frame)
    }

    public override init(frame: CGRect) {
        self.identifier = "annot\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0) // TO DO

        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets coordinates for the view.
    /// - Parameters:
    ///    - coordinates: Position of the view
    ///    - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setCoordinates(
        _ coordinates: CLLocationCoordinate2D,
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        self.coordinates = coordinates

        mapView.project(coordinates: coordinates) { result in
            switch result {
            case .success(let point):
                self.center = CGPoint(x: point.latitude, y: point.longitude)
                completionHandler?(.success(()))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }

    /// Adds custom annotation view to the map.
    /// - Parameters:
    ///    - mapView: Map view to add annotation to.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addTo(_ mapView: MTMapView, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        mapView.addContentDelegate(self)

        let zoom = mapView.getZoom { result in
            switch result {
            case .success(let zoom):
                let center = mapView.getCenter { result in
                    switch result {
                    case .success(let center):
                        let point = self.convertLatLonToPoint(
                            lat: self.coordinates.latitude,
                            lon: self.coordinates.longitude,
                            mapCenterLat: center.latitude,
                            mapCenterLon: center.longitude,
                            zoomLevel: zoom,
                            mapWidth: mapView.bounds.width,
                            mapHeight: mapView.bounds.height
                        )

                        self.center = point
                        mapView.addSubview(self)
                        mapView.bringSubviewToFront(self)

                        completionHandler?(.success(()))
                    case .failure(let error):
                        completionHandler?(.failure(error))
                    }
                }
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
    private func convertLatLonToPoint(
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
extension MTCustomAnnotationView {
    /// Adds annotation view to map DSL style.
    ///
    /// Prefer annotation.addTo instead.
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
