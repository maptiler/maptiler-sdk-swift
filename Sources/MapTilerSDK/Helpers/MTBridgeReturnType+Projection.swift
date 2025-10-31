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

        return MTProjectionType(rawValue: normalizedValue)
    }
}
