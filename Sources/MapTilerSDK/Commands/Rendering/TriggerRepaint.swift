//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  TriggerRepaint.swift
//  MapTilerSDK
//

package struct TriggerRepaint: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).triggerRepaint();"
    }
}
