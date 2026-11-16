//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetFilter.swift
//  MapTilerSDK
//

package struct GetFilter: MTValueCommand {
    let layerId: String

    package func toJS() -> String {
        return "JSON.stringify(\(MTBridge.mapObject).getFilter('\(layerId)')) ?? 'null';"
    }
}
