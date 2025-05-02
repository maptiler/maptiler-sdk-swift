//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTData.swift
//  MapTilerSDK
//

import CoreLocation

/// Object sent together with MTEvent.
public struct MTData: Codable {
    /// Unique id.
    public var id: String?

    /// Coordinate of the event tap.
    public var coordinate: CLLocationCoordinate2D?

    /// Point of the event tap.
    public var point: MTPoint?

    /// Type of the event.
    public var dataType: String?

    /// Boolean indicating if source is fully  loaded.
    public var isSourceLoaded: Bool?

    /// Source data.
    public var source: MTSourceData?

    /// Type of the source data.
    public var sourceDataType: String?

    /// Initialiaes the data from decoder.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.id) {
            id = try container.decode(String.self, forKey: .id)
        }

        if container.contains(.coordinate) {
            let coordinateData = try container.decode(LngLat.self, forKey: .coordinate)
            coordinate = CLLocationCoordinate2D(latitude: coordinateData.lat, longitude: coordinateData.lng)
        }

        if container.contains(.point) {
            point = try container.decode(MTPoint.self, forKey: .point)
        }

        if container.contains(.dataType) {
            dataType = try container.decode(String.self, forKey: .dataType)
        }

        if container.contains(.isSourceLoaded) {
            isSourceLoaded = try container.decode(Bool.self, forKey: .isSourceLoaded)
        }

        if container.contains(.source) {
            source = try container.decode(MTSourceData.self, forKey: .source)
        }

        if container.contains(.sourceDataType) {
            sourceDataType = try container.decode(String.self, forKey: .sourceDataType)
        }
    }

    package enum CodingKeys: String, CodingKey {
        case id
        case coordinate = "lngLat"
        case point
        case dataType
        case isSourceLoaded
        case source
        case sourceDataType
    }
}
