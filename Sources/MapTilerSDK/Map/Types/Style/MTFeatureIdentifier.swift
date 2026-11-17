//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTFeatureIdentifier.swift
//  MapTilerSDK
//

import Foundation

/// Identifies a specific feature in a vector or GeoJSON source.
public struct MTFeatureIdentifier: Codable, Sendable, Equatable {
    /// The ID of the source.
    public var source: String

    /// The source layer (required for vector tile sources).
    public var sourceLayer: String?

    /// The ID of the feature.
    public var id: ID

    /// Represents the ID of a feature, which can be either a string or an integer.
    public enum ID: Codable, Sendable, Equatable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
        case string(String)
        case int(Int)

        public init(stringLiteral value: String) { self = .string(value) }
        public init(integerLiteral value: Int) { self = .int(value) }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let i = try? container.decode(Int.self) {
                self = .int(i)
            } else if let s = try? container.decode(String.self) {
                self = .string(s)
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Feature ID must be an Int or String."
                )
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let s):
                try container.encode(s)
            case .int(let i):
                try container.encode(i)
            }
        }
    }

    public init(source: String, sourceLayer: String? = nil, id: ID) {
        self.source = source
        self.sourceLayer = sourceLayer
        self.id = id
    }
}
