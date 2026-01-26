//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTBridgeReturnType+Projection.swift
//  MapTilerSDK
//

import Foundation

package extension MTBridgeReturnType {
    var projectionValue: MTProjectionType? {
        guard case .string(let value) = self else {
            return nil
        }

        let normalizedValue = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Map known aliases to supported enum cases
        switch normalizedValue {
        case "vertical-perspective", "vertical_perspective", "verticalperspective", "perspective":
            return .globe
        default:
            return MTProjectionType(rawValue: normalizedValue)
        }
    }
}
