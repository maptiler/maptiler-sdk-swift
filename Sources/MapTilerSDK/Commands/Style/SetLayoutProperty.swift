//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetLayoutProperty.swift
//  MapTilerSDK
//

package struct SetLayoutProperty: MTCommand {
    let layerId: String
    let name: String
    let value: MTPropertyValue

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setLayoutProperty('\(layerId)', '\(name)', \(value.toJS()));"
    }
}
