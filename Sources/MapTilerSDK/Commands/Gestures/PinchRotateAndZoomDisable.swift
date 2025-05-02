//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PinchRotateAndZoomDisable.swift
//  MapTilerSDK
//

package struct PinchRotateAndZoomDisable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).touchZoomRotate.disable();"
    }
}
