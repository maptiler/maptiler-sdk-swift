//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetMarkerDraggable.swift
//  MapTilerSDK
//

package struct SetMarkerDraggable: MTCommand {
    var marker: MTMarker
    var draggable: Bool

    package func toJS() -> JSString {
        return "\(marker.identifier).setDraggable(\(draggable));"
    }
}
