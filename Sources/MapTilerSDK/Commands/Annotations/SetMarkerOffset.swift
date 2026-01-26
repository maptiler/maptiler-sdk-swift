//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetMarkerOffset.swift
//  MapTilerSDK
//

package struct SetMarkerOffset: MTCommand {
    var marker: MTMarker
    var offset: Double

    package func toJS() -> JSString {
        return "window.\(marker.identifier).setOffset([\(offset), \(offset)]);"
    }
}
