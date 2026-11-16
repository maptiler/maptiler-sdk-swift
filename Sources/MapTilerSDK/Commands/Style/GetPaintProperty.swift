//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetPaintProperty.swift
//  MapTilerSDK
//

package struct GetPaintProperty: MTValueCommand {
    let layerId: String
    let name: String

    package func toJS() -> String {
        return "JSON.stringify(\(MTBridge.mapObject).getPaintProperty('\(layerId)', '\(name)')) ?? 'null';"
    }
}
