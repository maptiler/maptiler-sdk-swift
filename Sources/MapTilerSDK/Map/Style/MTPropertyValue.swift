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
}
