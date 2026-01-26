//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ToggleMarkerPopup.swift
//  MapTilerSDK
//

package struct ToggleMarkerPopup: MTCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        return "window.\(marker.identifier).togglePopup();"
    }
}
