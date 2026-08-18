//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PointRotateAround.swift
//  MapTilerSDK
//

import Foundation

package struct PointRotateAround: MTValueCommand {
    var point: MTPoint
    var angle: Double
    var pivot: MTPoint

    package func toJS() -> JSString {
        let p = "new \(MTBridge.sdkObject).Point(\(point.x), \(point.y))"
        let pivotP = "new \(MTBridge.sdkObject).Point(\(pivot.x), \(pivot.y))"
        return "\(p).rotateAround(\(angle), \(pivotP));"
    }
}
