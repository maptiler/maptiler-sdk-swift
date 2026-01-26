//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMarkerCoordinates.swift
//  MapTilerSDK
//

package struct GetMarkerCoordinates: MTValueCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        return "(() => {\n" +
            "    const p = window.\(marker.identifier).getLngLat();\n" +
            "    return p ? { lat: p.lat, lng: p.lng } : null;\n" +
            "})();"
    }
}
