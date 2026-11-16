//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPropertyValue.swift
//  MapTilerSDK
//

import Foundation
import UIKit

/// A typed value container
public enum MTPropertyValue: Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case array([MTPropertyValue])
    case rawExpression(String)
    case color(UIColor)

    // Returns a style expression/value literal string.
    package func toJS() -> String {
        switch self {
        case .string(let s):
            // Encode as a JSON string safely using JSONEncoder (supports scalar top-level values)
            if let data = try? JSONEncoder().encode(s),
                let str = String(data: data, encoding: .utf8) {
                return str
            }
            // Fallback minimal escaping
            let escaped = s
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(escaped)\""
        case .number(let n):
            if n.rounded(.towardZero) == n { return String(format: "%.0f", n) }
            return String(n)
        case .bool(let b):
            return b ? "true" : "false"
        case .array(let arr):
            let items = arr.map { $0.toJS() }.joined(separator: ", ")
            return "[\(items)]"
        case .rawExpression(let js):
            return js
        case .color(let uiColor):
            return "\"\(uiColor.toHex())\""
        }
    }

    /// Parses a JSON string natively if possible, otherwise falls back to a raw JSON expression.
    package static func from(jsonString: String) -> MTPropertyValue? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) else {
            return .string(jsonString)
        }
        return from(any: jsonObject) ?? .rawExpression(jsonString)
    }

    private static func from(any: Any) -> MTPropertyValue? {
        if let b = any as? Bool { return .bool(b) }
        if let n = any as? Double { return .number(n) }
        if let s = any as? String { return .string(s) }
        if let a = any as? [Any] {
            let mapped = a.compactMap { from(any: $0) }
            if mapped.count == a.count { return .array(mapped) }
        }
        return nil
    }
}
