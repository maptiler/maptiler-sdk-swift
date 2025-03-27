//
//  MTGeoJSONSource.swift
//  MapTilerSDK
//

import Foundation

// A vector tile source.
public class MTGeoJSONSource: MTSource, @unchecked Sendable, Codable {
    public var identifier: String

    public var url: URL?

    public private(set) var type: MTSourceType = .geojson

    /// Attribution to be displayed when the map is shown to a user.
    public var attribution: String?

    /// Size of the tile buffer on each side.
    ///
    /// Optional number between 0 and 512 inclusive. A value of 0 produces no buffer.
    /// A value of 512 produces a buffer as wide as the tile itself.
    /// Larger values produce fewer rendering artifacts near tile edges and slower performance.
    /// - Note: Defaults to 128.
    public var buffer: Int? = 128

    /// If the data is a collection of point features, sets the points by radius into groups.
    ///
    /// - Note: Defaults to false.
    public var isCluster: Bool = false

    /// Max zoom on which to cluster points if clustering is enabled.
    ///
    /// Defaults to one zoom less than maxzoom (so that last zoom features are not clustered).
    public var clusterMaxZoom: Double?

    /// Radius of each cluster if clustering is enabled.
    ///
    /// A value of 512 indicates a radius equal to the width of a tile.
    /// - Note: Defaults to 50.
    public var clusterRadius: Double? = 50

    /// Maximum zoom level at which to create vector tiles.
    ///
    /// Higher value means greater detail at high zoom levels.
    /// - Note: Defaults to 18.
    public var maxZoom: Double? = 18

    /// Douglas-Peucker simplification tolerance.
    ///
    /// Higher value means simpler geometries and faster performance.
    /// - Note: Defaults to 0.375
    public var tolerance: Double? = 0.375

    /// Specifices whether to calculate line distance metrics
    public var lineMetrics: Bool? = false

    /// Initializes the source with unique id and url to TileJSON resource.
    public init(identifier: String, url: URL) {
        self.identifier = identifier
        self.url = url
    }

    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        identifier = try container.decode(String.self, forKey: .identifier)
        url = try URL(string: container.decode(String.self, forKey: .url))
        type = try container.decode(MTSourceType.self, forKey: .type)
        attribution = try container.decode(String.self, forKey: .attribution)
        buffer = try container.decode(Int.self, forKey: .buffer)
        isCluster = try container.decode(Bool.self, forKey: .isCluster)
        clusterMaxZoom = try container.decode(Double.self, forKey: .clusterMaxZoom)
        clusterRadius = try container.decode(Double.self, forKey: .clusterRadius)
        maxZoom = try container.decode(Double.self, forKey: .maxZoom)
        tolerance = try container.decode(Double.self, forKey: .tolerance)
        lineMetrics = try container.decode(Bool.self, forKey: .lineMetrics)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(url, forKey: .url)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(attribution, forKey: .attribution)
        try container.encode(buffer, forKey: .buffer)
        try container.encode(isCluster, forKey: .isCluster)
        try container.encodeIfPresent(clusterMaxZoom, forKey: .clusterMaxZoom)
        try container.encodeIfPresent(clusterRadius, forKey: .clusterRadius)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)
        try container.encodeIfPresent(tolerance, forKey: .tolerance)
        try container.encodeIfPresent(lineMetrics, forKey: .lineMetrics)
    }

    package enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case url = "data"
        case type
        case attribution
        case buffer
        case isCluster = "cluster"
        case clusterMaxZoom
        case clusterRadius
        case maxZoom = "maxzoom"
        case tolerance
        case lineMetrics
    }
}
