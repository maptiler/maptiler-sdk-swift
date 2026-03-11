//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  Repaint.swift
//  MapTilerSDK
//

package struct Repaint: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).triggerRepaint();"
    }
}
