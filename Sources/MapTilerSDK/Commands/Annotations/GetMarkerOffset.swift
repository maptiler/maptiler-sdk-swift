//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMarkerOffset.swift
//  MapTilerSDK
//

package struct GetMarkerOffset: MTValueCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        return "\(marker.identifier).getOffset().x;"
    }
}
