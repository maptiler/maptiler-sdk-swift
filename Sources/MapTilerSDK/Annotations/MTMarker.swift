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
    public func setCoordinates(_ coordinates: CLLocationCoordinate2D, in mapView: MTMapView) async {
        self.coordinates = coordinates

        await mapView.setCoordinatesTo(self)
    }
}
