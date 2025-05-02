//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetZoom.swift
//  MapTilerSDK
//

package struct SetZoom: MTCommand {
    var zoom: Double

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setZoom(\(zoom));"
    }
}
