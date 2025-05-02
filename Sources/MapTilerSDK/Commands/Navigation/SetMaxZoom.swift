//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetMaxZoom.swift
//  MapTilerSDK
//

package struct SetMaxZoom: MTCommand {
    let defaultZoom: Double = 22.0

    var maxZoom: Double?

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setMaxZoom(\(maxZoom ?? defaultZoom));"
    }
}
