//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTExpression.swift
//  MapTilerSDK
//

/// Helper to construct common style expressions without raw strings.
public enum MTExpression {
    /// ["get", key]
    public static func get(_ key: String) -> MTPropertyValue {
        .array([.string("get"), .string(key)])
    }

    /// ["get", key]
    public static func get(_ key: MTFeatureKey) -> MTPropertyValue {
        get(key.rawValue)
    }

    /// ["to-string", expr]
    public static func toString(_ value: MTPropertyValue) -> MTPropertyValue {
        .array([.string("to-string"), value])
    }

    /// step expression builder: ["step", input, default, t1, v1, t2, v2, ...]
    public static func step(
        input: MTPropertyValue,
        default defaultValue: MTPropertyValue,
        stops: [(Double, MTPropertyValue)]
    ) -> MTPropertyValue {
        var arr: [MTPropertyValue] = [.string("step"), input, defaultValue]
        for (threshold, value) in stops {
            arr.append(.number(threshold))
            arr.append(value)
        }
        return .array(arr)
    }
}
