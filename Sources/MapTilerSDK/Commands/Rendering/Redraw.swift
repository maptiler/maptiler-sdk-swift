//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  Redraw.swift
//  MapTilerSDK
//

package struct Redraw: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).redraw();"
    }
}
