//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTBridgeReturnType.swift
//  MapTilerSDK
//
import Foundation
import CoreFoundation

package enum MTBridgeReturnType: Sendable {
    case string(String)
    case double(Double)
    case bool(Bool)
    case stringDoubleDict([String: Double])
    case unsupportedType
    case null

    init(from value: Any?) throws {
        guard let value = value else { self = .null; return }

        if let str = value as? String { self = .string(str); return }
        if let dbl = value as? Double { self = .double(dbl); return }
        if let boo = value as? Bool { self = .bool(boo); return }
        if let dict = value as? [String: Double] { self = .stringDoubleDict(dict); return }

        if let num = value as? NSNumber {
            if CFGetTypeID(num) == CFBooleanGetTypeID() {
                self = .bool(num.boolValue)
            } else {
                self = .double(num.doubleValue)
            }
            return
        }

        if let intv = value as? Int { self = .double(Double(intv)); return }

        throw MTError.invalidResultType(description: String(describing: type(of: value)))
    }
}
