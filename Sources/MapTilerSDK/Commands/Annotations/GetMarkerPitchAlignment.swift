//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMarkerPitchAlignment.swift
//  MapTilerSDK
//

package struct GetMarkerPitchAlignment: MTCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        return "\(marker.identifier).getPitchAlignment();"
    }
}
