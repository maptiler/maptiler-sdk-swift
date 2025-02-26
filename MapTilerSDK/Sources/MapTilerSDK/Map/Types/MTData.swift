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

        if container.contains(.coordinate) {
            let coordinateData = try container.decode(LngLat.self, forKey: .coordinate)
            coordinate = CLLocationCoordinate2D(latitude: coordinateData.lng, longitude: coordinateData.lat)
        }

        if container.contains(.source) {
            source = try container.decode(MTSourceData.self, forKey: .source)
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
