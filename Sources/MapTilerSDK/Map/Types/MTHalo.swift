//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTHalo.swift
//  MapTilerSDK
//

import Foundation

/// One stop in the halo radial gradient: position in [0,1] and color.
public struct MTHaloStop: Sendable, Codable {
    public var position: Double
    public var color: MTColor

    public init(position: Double, color: MTColor) {
        self.position = position
        self.color = color
    }

    public init(from decoder: any Decoder) throws {
        // Expecting a two-element array: [position, color]
        var container = try decoder.unkeyedContainer()
        let position = try container.decode(Double.self)

        // Color can be provided as a hex/rgb string or as MTColor encoded object
        if let colorString = try? container.decode(String.self) {
            self.color = MTColor(hex: colorString)
        } else if let colorObject = try? container.decode(MTColor.self) {
            self.color = colorObject
        } else {
            // Fallback to empty color if decoding fails
            self.color = MTColor(hex: "#00000000")
        }

        self.position = position
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(position)
        try container.encode(color.hex)
    }
}

/// Configuration for the atmospheric glow (halo).
public struct MTHalo: Sendable, Codable {
    /// Controls the overall halo size.
    public var scale: Double?

    /// Radial gradient definition expressed as ordered stops.
    public var stops: [MTHaloStop]?

    public init(scale: Double? = nil, stops: [MTHaloStop]? = nil) {
        self.scale = scale
        self.stops = stops
    }
}

/// Option that can enable default halo or configure it.
public enum MTHaloOption: Sendable, Codable {
    case enabled(Bool)
    case config(MTHalo)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let boolValue = try? container.decode(Bool.self) {
            self = .enabled(boolValue)
            return
        }

        let value = try container.decode(MTHalo.self)
        self = .config(value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .enabled(let flag):
            try container.encode(flag)
        case .config(let value):
            try container.encode(value)
        }
    }
}
