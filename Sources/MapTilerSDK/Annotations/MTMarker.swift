//
//  MTMarker.swift
//  MapTilerSDK
//

import UIKit
import CoreLocation

/// Annotation element that can be added to the map.
public class MTMarker: MTAnnotation, @unchecked Sendable {
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

    /// Initializes the marker with the specified position.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
    public init(coordinates: CLLocationCoordinate2D) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
    }

    /// Sets coordinates for the marker.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
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
extension MTMarker {
    /// Sets coordinates for the marker.
    /// - Parameters:
    ///    - coordinates: Position of the marker.
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
