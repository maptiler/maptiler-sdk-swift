//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  TouchZoomRotateEnable.swift
//  MapTilerSDK
//

package struct PinchRotateAndZoomEnable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).touchZoomRotate.enable();"
    }
}
