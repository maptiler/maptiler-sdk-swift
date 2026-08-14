//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PointMatMult.swift
//  MapTilerSDK
//

import Foundation

package struct PointMatMult: MTValueCommand {
    var point: MTPoint
    var m: [Double]

    package func toJS() -> JSString {
        let p = "new \(MTBridge.sdkObject).Point(\(point.x), \(point.y))"
        let matrix = "[\(m.map { String($0) }.joined(separator: ", "))]"
        return "\(p).matMult(\(matrix));"
    }
}
