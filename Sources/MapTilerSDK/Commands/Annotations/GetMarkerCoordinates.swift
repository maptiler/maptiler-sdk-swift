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
        return """
        (() => {
            const p = window.\(marker.identifier).getLngLat();
            return p ? { lat: p.lat, lng: p.lng } : null;
        })();
        """
    }
}
