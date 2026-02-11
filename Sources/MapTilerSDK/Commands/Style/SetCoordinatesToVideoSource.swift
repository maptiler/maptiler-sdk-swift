//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetCoordinatesToVideoSource.swift
//  MapTilerSDK
//

import Foundation

package struct SetCoordinatesToVideoSource: MTCommand {
    var source: MTSource
    var coordinates: [[Double]]

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getSource('\(source.identifier)').setCoordinates(\(coordinates));"
    }
}
