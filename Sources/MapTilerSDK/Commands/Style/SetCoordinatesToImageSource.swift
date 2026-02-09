//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetCoordinatesToImageSource.swift
//  MapTilerSDK
//

import Foundation

package struct SetCoordinatesToImageSource: MTCommand {
    var source: MTSource
    var coordinates: [[Double]]

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getSource('\(source.identifier)').setCoordinates(\(coordinates));"
    }
}
