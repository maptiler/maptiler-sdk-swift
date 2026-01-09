//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTHelperValueTypes.swift
//  MapTilerSDK
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Array of string values that depend on zoom level.
public typealias MTZoomStringValues = [MTZoomStringValue]

/// A single string value at a given zoom level.
public struct MTZoomStringValue: Codable, Sendable {
    /// Zoom level
    public var zoom: Double
    /// Value for the given zoom level
    public var value: String

    public init(zoom: Double, value: String) {
        self.zoom = zoom
        self.value = value
    }
}

/// Array of number values that depend on zoom level.
public typealias MTZoomNumberValues = [MTZoomNumberValue]

/// A single numeric value at a given zoom level.
public struct MTZoomNumberValue: Codable, Sendable {
    /// Zoom level
    public var zoom: Double
    /// Value for the given zoom level
    public var value: Double

    public init(zoom: Double, value: Double) {
        self.zoom = zoom
        self.value = value
    }
}

/// Array mapping a property input value to an associated numeric output value.
public typealias MTPropertyValues = [MTHelperPropertyValue]

/// A single mapping from a property value to an associated numeric value.
public struct MTHelperPropertyValue: Codable, Sendable {
    /// Value of the property (input)
    public var propertyValue: Double
    /// Value to associate it with (output)
    public var value: Double

    public init(propertyValue: Double, value: Double) {
        self.propertyValue = propertyValue
        self.value = value
    }
}

// MARK: - Colors

/// Encodes a color to a hex string when converted to JSON.
/// Accepts either a hex color string (e.g. "#RRGGBB") or a UIColor.
public struct MTColorValue: Codable, Sendable {
    public let raw: String

    public init(_ hexColor: String) {
        self.raw = hexColor
    }

    #if canImport(UIKit)
    public init(_ color: UIColor) {
        self.raw = MTColorValue.hexString(from: color)
    }
    #endif

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.raw = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(raw)
    }

    #if canImport(UIKit)
    private static func hexString(from color: UIColor) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard color.getRed(&r, &g, &b, &a) else { return "#000000" }
        let ri = Int(round(r * 255)), gi = Int(round(g * 255)), bi = Int(round(b * 255)), ai = Int(round(a * 255))
        if ai < 255 {
            return String(format: "#%02X%02X%02X%02X", ri, gi, bi, ai)
        } else {
            return String(format: "#%02X%02X%02X", ri, gi, bi)
        }
    }
    #endif
}

// MARK: - Union helper types for encoding mixed-value options

/// Either a numeric value or zoom-ramped numeric values.
public enum MTNumberOrZoomNumberValues: Codable, Sendable {
    case number(Double)
    case ramp(MTZoomNumberValues)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(Double.self) {
            self = .number(v)
        } else if let v = try? container.decode([MTZoomNumberValue].self) {
            self = .ramp(v)
        } else {
            throw DecodingError.typeMismatch(
                MTNumberOrZoomNumberValues.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected Double or [MTZoomNumberValue]"
                )
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .number(v):
            try container.encode(v)
        case let .ramp(v):
            try container.encode(v)
        }
    }
}

/// Either a string value or zoom-ramped string values.
public enum MTStringOrZoomStringValues: Codable, Sendable {
    case string(String)
    case ramp(MTZoomStringValues)
    #if canImport(UIKit)
    case uiColor(UIColor)
    #endif

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(String.self) {
            self = .string(v)
        } else if let v = try? container.decode([MTZoomStringValue].self) {
            self = .ramp(v)
        } else {
            throw DecodingError.typeMismatch(
                MTStringOrZoomStringValues.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected String or [MTZoomStringValue]"
                )
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(v):
            try container.encode(v)
        case let .ramp(v):
            try container.encode(v)
        #if canImport(UIKit)
        case let .uiColor(color):
            try container.encode(MTColorValue.hexString(from: color))
        #endif
        }
    }
}

#if canImport(UIKit)
public extension MTStringOrZoomStringValues {
    init(_ color: UIColor) {
        self = .uiColor(color)
    }
}
#endif

/// Either a numeric value or property-mapped numeric values.
public enum MTNumberOrPropertyValues: Codable, Sendable {
    case number(Double)
    case propertyValues(MTPropertyValues)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(Double.self) {
            self = .number(v)
        } else if let v = try? container.decode([MTHelperPropertyValue].self) {
            self = .propertyValues(v)
        } else {
            throw DecodingError.typeMismatch(
                MTNumberOrPropertyValues.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected Double or [MTHelperPropertyValue]"
                )
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .number(v):
            try container.encode(v)
        case let .propertyValues(v):
            try container.encode(v)
        }
    }
}

/// Heatmap radius can be a number, zoom-ramped numbers, or property-mapped numbers.
public enum MTRadiusOption: Codable, Sendable {
    case number(Double)
    case zoom(MTZoomNumberValues)
    case property(MTPropertyValues)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(Double.self) {
            self = .number(v)
        } else if let v = try? container.decode([MTZoomNumberValue].self) {
            self = .zoom(v)
        } else if let v = try? container.decode([MTHelperPropertyValue].self) {
            self = .property(v)
        } else {
            throw DecodingError.typeMismatch(
                MTRadiusOption.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected Double or [MTZoomNumberValue] or [MTHelperPropertyValue]"
                )
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .number(v):
            try container.encode(v)
        case let .zoom(v):
            try container.encode(v)
        case let .property(v):
            try container.encode(v)
        }
    }
}
