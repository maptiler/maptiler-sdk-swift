//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ZoomIn.swift
//  MapTilerSDK
//

package struct ZoomIn: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).zoomIn();"
    }
}
