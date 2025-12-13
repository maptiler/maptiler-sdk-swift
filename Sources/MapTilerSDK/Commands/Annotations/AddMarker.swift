//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddMarker.swift
//  MapTilerSDK
//

import UIKit

package struct AddMarker: MTCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        let coordinates = marker.coordinates.toLngLat()

        var iconInit = ""
        var iconData = ""
        var popupAttachment = ""
        var markerOptions: [String] = [
            "color: '\(marker.color?.toHex() ?? UIColor.blue.toHex())'",
            "opacity: \(marker.opacity)",
            "opacityWhenCovered: \(marker.opacityWhenCovered)",
            "draggable: \(marker.draggable ?? false)",
            "anchor: '\(marker.anchor.rawValue)'",
            "offset: [\(marker.offset), \(marker.offset)]"
        ]

        let drag = """
            function onDrag() {
                var markerCoord = \(marker.identifier).getLngLat();
                var data = {
                    id: '\(marker.identifier)',
                    lngLat: markerCoord
                };

                window.webkit.messageHandlers.mapHandler.postMessage({
                    event: 'drag',
                    data: data
                });
            };

            \(marker.identifier).on('drag', onDrag);
        """

        if let popup = marker.popup {
            popupAttachment = """
                const \(popup.identifier) = new maptilersdk.Popup({ offset: \(popup.offset ?? 0) });

                \(popup.identifier)
                .setText('\(popup.text)')
                """
        }

        let popupString = marker.popup != nil ? "\(marker.identifier).setPopup(\(marker.popup!.identifier))" : ""

        if let icon = marker.icon, let encodedImageString = icon.getEncodedString() {
            iconInit = """
            var icon\(marker.identifier) = new Image();
            icon\(marker.identifier).src = 'data:image/png;base64,\(encodedImageString)';
        """

            iconData = "element: icon\(marker.identifier)"
        }

        if !iconData.isEmpty {
            markerOptions.append(iconData)
        }

        let optionsString = markerOptions.joined(separator: ",\n                ")

        return """
            \(popupAttachment)

            \(iconInit)

            const \(marker.identifier) = new maptilersdk.Marker({
                \(optionsString)
            });

            \(popupString)

            \(marker.identifier)
            .setLngLat([\(coordinates.lng), \(coordinates.lat)])
            .addTo(\(MTBridge.mapObject));

            \(drag)
            """
    }
}
