//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsMarkerDraggable.swift
//  MapTilerSDK
//

package struct IsMarkerDraggable: MTCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        return "\(marker.identifier).isDraggable();"
    }
}
