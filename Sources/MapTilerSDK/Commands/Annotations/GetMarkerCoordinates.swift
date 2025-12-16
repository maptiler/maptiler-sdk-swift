//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMarkerCoordinates.swift
//  MapTilerSDK
//

package struct GetMarkerCoordinates: MTCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        return "\(marker.identifier).getLngLat();"
    }
}
