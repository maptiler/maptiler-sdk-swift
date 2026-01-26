//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMarkerRotation.swift
//  MapTilerSDK
//

package struct GetMarkerRotation: MTValueCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        return "window.\(marker.identifier).getRotation();"
    }
}
