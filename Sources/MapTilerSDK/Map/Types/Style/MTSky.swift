//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTSky.swift
//  MapTilerSDK
//

import Foundation
import UIKit

/// Expression element used to build MapTiler style expressions for sky values.
public enum MTSkyExpression: Sendable, Codable, Equatable {
    case string(String)
    case number(Double)
    case array([MTSkyExpression])

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            let nested = try container.decode([MTSkyExpression].self)
            self = .array(nested)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .array(let values):
            try container.encode(values)
        }
    }
}

/// Represents a color or expression for the sky configuration.
public enum MTSkyColorValue: Sendable, Codable, Equatable {
    case color(MTColor)
    case expression([MTSkyExpression])

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let colorString = try? container.decode(String.self) {
            self = .color(MTColor(hex: colorString))
            return
        }

        if let colorObject = try? container.decode(MTColor.self) {
            self = .color(colorObject)
            return
        }

        let expression = try container.decode([MTSkyExpression].self)
        self = .expression(expression)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .color(let color):
            try container.encode(color.hex)
        case .expression(let expression):
            try container.encode(expression)
        }
    }

    /// Convenience to wrap a UIKit color.
    public static func color(_ color: UIColor) -> MTSkyColorValue {
        return .color(MTColor(color: color.cgColor))
    }
}

/// Represents a numeric value or expression for the sky configuration.
public enum MTSkyNumberValue: Sendable, Codable, Equatable {
    case number(Double)
    case expression([MTSkyExpression])

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let number = try? container.decode(Double.self) {
            self = .number(number)
            return
        }

        let expression = try container.decode([MTSkyExpression].self)
        self = .expression(expression)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch clamped() {
        case .number(let number):
            try container.encode(number)
        case .expression(let expression):
            try container.encode(expression)
        }
    }

    /// Clamps numeric values to the valid [0, 1] range.
    public func clamped() -> MTSkyNumberValue {
        switch self {
        case .number(let value):
            return .number(max(0, min(1, value)))
        case .expression:
            return self
        }
    }
}

/// Sky configuration used by `map.setSky`.
public struct MTSky: Sendable, Codable, Equatable {
    /// The base color of the sky.
    public var skyColor: MTSkyColorValue?

    /// How to blend the sky color with the horizon in the [0, 1] range.
    public var skyHorizonBlend: MTSkyNumberValue?

    /// The base color at the horizon.
    public var horizonColor: MTSkyColorValue?

    /// How to blend the fog and horizon colors in the [0, 1] range.
    public var horizonFogBlend: MTSkyNumberValue?

    /// The base color for the fog (requires 3D terrain).
    public var fogColor: MTSkyColorValue?

    /// How to blend fog over the terrain in the [0, 1] range.
    public var fogGroundBlend: MTSkyNumberValue?

    /// How to blend the atmosphere in the [0, 1] range.
    public var atmosphereBlend: MTSkyNumberValue?

    public init(
        skyColor: MTSkyColorValue? = nil,
        skyHorizonBlend: MTSkyNumberValue? = nil,
        horizonColor: MTSkyColorValue? = nil,
        horizonFogBlend: MTSkyNumberValue? = nil,
        fogColor: MTSkyColorValue? = nil,
        fogGroundBlend: MTSkyNumberValue? = nil,
        atmosphereBlend: MTSkyNumberValue? = nil
    ) {
        self.skyColor = skyColor
        self.skyHorizonBlend = skyHorizonBlend?.clamped()
        self.horizonColor = horizonColor
        self.horizonFogBlend = horizonFogBlend?.clamped()
        self.fogColor = fogColor
        self.fogGroundBlend = fogGroundBlend?.clamped()
        self.atmosphereBlend = atmosphereBlend?.clamped()
    }

    enum CodingKeys: String, CodingKey {
        case skyColor = "sky-color"
        case skyHorizonBlend = "sky-horizon-blend"
        case horizonColor = "horizon-color"
        case horizonFogBlend = "horizon-fog-blend"
        case fogColor = "fog-color"
        case fogGroundBlend = "fog-ground-blend"
        case atmosphereBlend = "atmosphere-blend"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.skyColor = try container.decodeIfPresent(MTSkyColorValue.self, forKey: .skyColor)
        self.skyHorizonBlend = try container.decodeIfPresent(MTSkyNumberValue.self, forKey: .skyHorizonBlend)?
            .clamped()
        self.horizonColor = try container.decodeIfPresent(MTSkyColorValue.self, forKey: .horizonColor)
        self.horizonFogBlend = try container.decodeIfPresent(MTSkyNumberValue.self, forKey: .horizonFogBlend)?
            .clamped()
        self.fogColor = try container.decodeIfPresent(MTSkyColorValue.self, forKey: .fogColor)
        self.fogGroundBlend = try container.decodeIfPresent(MTSkyNumberValue.self, forKey: .fogGroundBlend)?
            .clamped()
        self.atmosphereBlend = try container.decodeIfPresent(MTSkyNumberValue.self, forKey: .atmosphereBlend)?
            .clamped()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let skyColor {
            try container.encode(skyColor, forKey: .skyColor)
        }

        if let skyHorizonBlend {
            try container.encode(skyHorizonBlend.clamped(), forKey: .skyHorizonBlend)
        }

        if let horizonColor {
            try container.encode(horizonColor, forKey: .horizonColor)
        }

        if let horizonFogBlend {
            try container.encode(horizonFogBlend.clamped(), forKey: .horizonFogBlend)
        }

        if let fogColor {
            try container.encode(fogColor, forKey: .fogColor)
        }

        if let fogGroundBlend {
            try container.encode(fogGroundBlend.clamped(), forKey: .fogGroundBlend)
        }

        if let atmosphereBlend {
            try container.encode(atmosphereBlend.clamped(), forKey: .atmosphereBlend)
        }
    }
}
