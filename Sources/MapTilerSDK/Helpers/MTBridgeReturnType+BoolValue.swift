//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTBridgeReturnType+BoolValue.swift
//  MapTilerSDK
//

import Foundation

package extension MTBridgeReturnType {
    var boolValue: Bool? {
        switch self {
        case .bool(let value):
            return value
        case .double(let value):
            return value != 0
        case .string(let value):
            let normalizedValue = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

            if normalizedValue == "true" {
                return true
            }

            if normalizedValue == "false" {
                return false
            }

            guard let doubleValue = Double(normalizedValue) else {
                return nil
            }

            return doubleValue != 0
        default:
            return nil
        }
    }
}
