//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetMinZoom.swift
//  MapTilerSDK
//

package struct SetMinZoom: MTCommand {
    let defaultZoom: Double = -2.0

    var minZoom: Double?

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setMinZoom(\(minZoom ?? defaultZoom));"
    }
}
