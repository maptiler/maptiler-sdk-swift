//
//  MTData.swift
//  MapTilerSDK
//

import CoreLocation

/// Object sent together with MTEvent.
public struct MTData: Codable {
    public var id: String?
    public var coordinate: CLLocationCoordinate2D?
    public var point: MTPoint?
    public var dataType: String?
    public var isSourceLoaded: Bool?
    public var source: MTSourceData?
    public var sourceDataType: String?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.id) {
            id = try container.decode(String.self, forKey: .id)
        }

        if container.contains(.coordinate) {
            let coordinateData = try container.decode(LngLat.self, forKey: .coordinate)
            coordinate = CLLocationCoordinate2D(latitude: coordinateData.lng, longitude: coordinateData.lat)
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
