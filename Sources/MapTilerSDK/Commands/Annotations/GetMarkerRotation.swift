//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMarkerRotation.swift
//  MapTilerSDK
//

package struct GetMarkerRotation: MTCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        return "\(marker.identifier).getRotation();"
    }
}
