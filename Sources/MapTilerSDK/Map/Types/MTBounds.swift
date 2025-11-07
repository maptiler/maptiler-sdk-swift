//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTBounds.swift
//  MapTilerSDK
//

import CoreLocation

/// Represents rectangular geographic bounds defined by southwest and northeast corners.
public struct MTBounds: Sendable, Codable, Equatable {
    /// Southwest corner of the bounds.
    public var southWest: CLLocationCoordinate2D

    /// Northeast corner of the bounds.
    public var northEast: CLLocationCoordinate2D

    /// Creates a new bounds instance.
    /// - Parameters:
    ///   - southWest: The southwest corner coordinate.
    ///   - northEast: The northeast corner coordinate.
    public init(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D) {
        self.southWest = southWest
        self.northEast = northEast
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let southWest = try container.decode(CLLocationCoordinate2D.self)
        let northEast = try container.decode(CLLocationCoordinate2D.self)

        self.init(southWest: southWest, northEast: northEast)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(southWest)
        try container.encode(northEast)
    }
}
