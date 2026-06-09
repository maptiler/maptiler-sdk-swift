//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PointAngleWithSep.swift
//  MapTilerSDK
//

import Foundation

package struct PointAngleWithSep: MTValueCommand {
    var point: MTPoint
    var x: Double
    var y: Double

    package func toJS() -> JSString {
        let p = "new \(MTBridge.sdkObject).Point(\(point.x), \(point.y))"
        return "\(p).angleWithSep(\(x), \(y));"
    }
}
