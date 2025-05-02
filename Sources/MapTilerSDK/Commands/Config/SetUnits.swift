//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetUnits.swift
//  MapTilerSDK
//

package struct SetUnits: MTCommand {
    var unit: MTUnit

    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).config.unit = '\(unit.rawValue)';"
    }
}
