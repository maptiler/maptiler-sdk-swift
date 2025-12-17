//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetMarkerRotation.swift
//  MapTilerSDK
//

package struct SetMarkerRotation: MTCommand {
    var marker: MTMarker
    var rotation: Double

    package func toJS() -> JSString {
        return "\(marker.identifier).setRotation(\(rotation));"
    }
}
