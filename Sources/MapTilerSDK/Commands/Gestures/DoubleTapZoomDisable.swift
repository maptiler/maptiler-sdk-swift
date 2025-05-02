//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  DoubleTapZoomDisable.swift
//  MapTilerSDK
//

package struct DoubleTapZoomDisable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).doubleClickZoom.disable();"
    }
}
