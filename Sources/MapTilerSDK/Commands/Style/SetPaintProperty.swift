//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetPaintProperty.swift
//  MapTilerSDK
//

package struct SetPaintProperty: MTCommand {
    let layerId: String
    let name: String
    let value: MTPropertyValue

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setPaintProperty('\(layerId)', '\(name)', \(value.toJS()));"
    }
}
