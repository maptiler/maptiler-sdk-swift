//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetLayoutProperty.swift
//  MapTilerSDK
//

package struct GetLayoutProperty: MTValueCommand {
    let layerId: String
    let name: String

    package func toJS() -> String {
        return "JSON.stringify(\(MTBridge.mapObject).getLayoutProperty('\(layerId)', '\(name)')) ?? 'null';"
    }
}
