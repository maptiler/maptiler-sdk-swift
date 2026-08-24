//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PointSub.swift
//  MapTilerSDK
//

import Foundation

package struct PointSub: MTValueCommand {
    var point1: MTPoint
    var point2: MTPoint

    package func toJS() -> JSString {
        let p1 = "new \(MTBridge.sdkObject).Point(\(point1.x), \(point1.y))"
        let p2 = "new \(MTBridge.sdkObject).Point(\(point2.x), \(point2.y))"
        return "\(p1).sub(\(p2));"
    }
}
