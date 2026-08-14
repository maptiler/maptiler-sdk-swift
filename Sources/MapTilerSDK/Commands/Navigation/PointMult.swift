//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PointMult.swift
//  MapTilerSDK
//

import Foundation

package struct PointMult: MTValueCommand {
    var point: MTPoint
    var k: Double

    package func toJS() -> JSString {
        let p = "new \(MTBridge.sdkObject).Point(\(point.x), \(point.y))"
        return "\(p).mult(\(k));"
    }
}
