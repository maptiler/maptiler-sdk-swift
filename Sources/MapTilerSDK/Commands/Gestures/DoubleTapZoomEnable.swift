//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  DoubleTapZoomEnable.swift
//  MapTilerSDK
//

package struct DoubleTapZoomEnable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).doubleClickZoom.enable();"
    }
}
