//
//  MTLight.swift
//  MapTilerSDK
//

import UIKit

/// Sets whether extruded geometries are lit relative to the map or viewport.
public enum MTLightAnchor: String, Sendable, Codable {
    /// The position of the light source is aligned to the rotation of the map.
    case map

    /// The position of the light source is aligned to the rotation of the viewport.
    case viewport
}

/// A style’s light property provides a global light source for that style.
public struct MTLight: Sendable, Codable {
    /// Optional anchor enum.
    var anchor: MTLightAnchor?

    /// Optional color. Defaults to white.
    var color: MTColor?

    /// Intensity of lighting (on a scale from 0 to 1).
    var intensity: Double?

    /// Optional array of numbers. Defaults to [1.15,210,30].
    var position: [Double]?

    public init(
        anchor: MTLightAnchor? = nil,
        color: MTColor? = nil,
        intensity: Double? = nil,
        position: [Double]? = nil
    ) {
        self.anchor = anchor
        self.color = color
        self.intensity = intensity
        self.position = position
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.anchor = try container.decode(MTLightAnchor.self, forKey: .anchor)
        self.color = try container.decode(MTColor.self, forKey: .color)
        self.intensity = try container.decode(Double.self, forKey: .intensity)
        self.position = try container.decode([Double].self, forKey: .position)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let anchor {
            try container.encode(anchor, forKey: .anchor)
        }

        if let color {
            try container.encode(color.hex, forKey: .color)
        }

        if let intensity {
            try container.encode(intensity, forKey: .intensity)
        }

        if let position {
            try container.encode(position, forKey: .position)
        }
    }

    package enum CodingKeys: String, CodingKey {
        case anchor
        case color
        case intensity
        case position
    }
}
