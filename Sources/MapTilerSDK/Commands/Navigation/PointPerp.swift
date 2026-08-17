//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PointPerp.swift
//  MapTilerSDK
//

import Foundation

package struct PointPerp: MTValueCommand {
    var point: MTPoint

    package func toJS() -> JSString {
        let p = "new \(MTBridge.sdkObject).Point(\(point.x), \(point.y))"
        return "\(p).perp();"
    }
}
