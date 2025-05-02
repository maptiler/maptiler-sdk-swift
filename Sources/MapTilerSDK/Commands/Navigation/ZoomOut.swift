//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ZoomOut.swift
//  MapTilerSDK
//

package struct ZoomOut: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).zoomOut();"
    }
}
