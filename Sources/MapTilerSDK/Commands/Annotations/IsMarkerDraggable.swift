//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsMarkerDraggable.swift
//  MapTilerSDK
//

package struct IsMarkerDraggable: MTValueCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        return "window.\(marker.identifier).isDraggable();"
    }
}
