//
//  MTMarker.swift
//  MapTilerSDK
//

import UIKit
import CoreLocation

public class MTMarker: MTAnnotation, @unchecked Sendable {
    public private(set) var identifier: String
    public private(set) var coordinates: CLLocationCoordinate2D

    public var color: UIColor?
    public var draggable: Bool?

    public init(coordinates: CLLocationCoordinate2D) {
        self.identifier = "mark\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.coordinates = coordinates
    }

    public func setCoordinates(_ coordinates: CLLocationCoordinate2D, in mapView: MTMapView) async {
        self.coordinates = coordinates

        await mapView.setCoordinatesTo(self)
    }
}
