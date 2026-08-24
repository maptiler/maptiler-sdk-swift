//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PointUnit.swift
//  MapTilerSDK
//

import Foundation

package struct PointUnit: MTValueCommand {
    var point: MTPoint

    package func toJS() -> JSString {
        let p = "new \(MTBridge.sdkObject).Point(\(point.x), \(point.y))"
        return "\(p).unit();"
    }
}
