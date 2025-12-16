//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMarkerRotationAlignment.swift
//  MapTilerSDK
//

package struct GetMarkerRotationAlignment: MTCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        return "\(marker.identifier).getRotationAlignment();"
    }
}
