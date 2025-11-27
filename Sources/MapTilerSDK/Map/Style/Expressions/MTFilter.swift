//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTFilter.swift
//  MapTilerSDK
//

/// Helper to construct common filter expressions without raw strings.
public enum MTFilter {
    /// ["has", key]
    public static func has(_ key: String) -> MTPropertyValue {
        .array([.string("has"), .string(key)])
    }

    /// ["has", key]
    public static func has(_ key: MTFeatureKey) -> MTPropertyValue {
        has(key.rawValue)
    }

    /// ["!", filter]
    public static func not(_ filter: MTPropertyValue) -> MTPropertyValue {
        .array([.string("!"), filter])
    }

    /// ["==", ["get", key], value]
    public static func eq(_ key: String, _ value: MTPropertyValue) -> MTPropertyValue {
        .array([.string("=="), MTExpression.get(key), value])
    }

    /// ["==", ["get", key], value]
    public static func eq(_ key: MTFeatureKey, _ value: MTPropertyValue) -> MTPropertyValue {
        .array([.string("=="), MTExpression.get(key), value])
    }

    /// ["all", ...filters]
    public static func all(_ filters: [MTPropertyValue]) -> MTPropertyValue {
        .array([.string("all")] + filters)
    }

    /// ["any", ...filters]
    public static func any(_ filters: [MTPropertyValue]) -> MTPropertyValue {
        .array([.string("any")] + filters)
    }
}

public extension MTFilter {
    /// Convenience: filter for clusters (features having point_count)
    static func clusters() -> MTPropertyValue { has(.pointCount) }

    /// Convenience: filter for non-clustered points (![has point_count])
    static func unclustered() -> MTPropertyValue { not(has(.pointCount)) }
}
