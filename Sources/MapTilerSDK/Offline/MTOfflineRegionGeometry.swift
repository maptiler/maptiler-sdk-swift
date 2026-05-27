//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineRegionGeometry.swift
//  MapTilerSDK
//

import Foundation
import CoreLocation

/// Represents the geometry of an offline region.
public enum MTOfflineRegionGeometry: Codable, Equatable, Sendable {
    /// A rectangular bounding box.
    case boundingBox(MTBoundingBox)
    /// A route defined by a series of coordinates.
    case route([CLLocationCoordinate2D])

    /// The bounding box that contains the entire geometry.
    public var bbox: MTBoundingBox {
        switch self {
        case .boundingBox(let box):
            return box
        case .route(let coordinates):
            return MTBoundingBox(from: coordinates)
        }
    }
}

extension MTBoundingBox {
    /// Creates a bounding box that contains all the given coordinates.
    /// - Parameter coordinates: The coordinates to include.
    public init(from coordinates: [CLLocationCoordinate2D]) {
        guard !coordinates.isEmpty else {
            self.init(minLon: 0, minLat: 0, maxLon: 0, maxLat: 0)
            return
        }

        var minLon = Double.greatestFiniteMagnitude
        var minLat = Double.greatestFiniteMagnitude
        var maxLon = -Double.greatestFiniteMagnitude
        var maxLat = -Double.greatestFiniteMagnitude

        for coord in coordinates {
            minLon = min(minLon, coord.longitude)
            minLat = min(minLat, coord.latitude)
            maxLon = max(maxLon, coord.longitude)
            maxLat = max(maxLat, coord.latitude)
        }

        self.init(minLon: minLon, minLat: minLat, maxLon: maxLon, maxLat: maxLat)
    }
}
