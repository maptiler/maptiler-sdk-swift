//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  RemoveMarkers.swift
//  MapTilerSDK
//

package struct RemoveMarkers: MTCommand {
    var markers: [MTMarker]

    package func toJS() -> JSString {
        var jsString = ""

        for marker in markers {
            jsString.append("\n")
            jsString.append("\(marker.identifier).remove();")
        }

        return jsString
    }
}
