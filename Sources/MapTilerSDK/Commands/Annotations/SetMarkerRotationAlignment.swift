//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetMarkerRotationAlignment.swift
//  MapTilerSDK
//

package struct SetMarkerRotationAlignment: MTCommand {
    var marker: MTMarker
    var alignment: MTMarkerRotationAlignment

    package func toJS() -> JSString {
        return "\(marker.identifier).setRotationAlignment('\(alignment.rawValue)');"
    }
}
