//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetFilter.swift
//  MapTilerSDK
//

package struct SetFilter: MTCommand {
    let layerId: String
    let filter: MTPropertyValue

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setFilter('\(layerId)', \(filter.toJS()));"
    }
}
