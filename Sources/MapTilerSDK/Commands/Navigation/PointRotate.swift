//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PointRotate.swift
//  MapTilerSDK
//

import Foundation

package struct PointRotate: MTValueCommand {
    var point: MTPoint
    var angle: Double

    package func toJS() -> JSString {
        let p = "new \(MTBridge.sdkObject).Point(\(point.x), \(point.y))"
        return "\(p).rotate(\(angle));"
    }
}
