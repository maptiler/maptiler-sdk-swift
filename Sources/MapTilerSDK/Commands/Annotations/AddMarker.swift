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
            "offset: [\(marker.offset), \(marker.offset)]",
            "scale: \(marker.scale)",
            "subpixelPositioning: \(marker.subpixelPositioning)",
            "rotation: \(marker.rotation)",
            "rotationAlignment: '\(marker.rotationAlignment.rawValue)'",
            "pitchAlignment: '\(marker.pitchAlignment.rawValue)'"
        ]

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

            \(markerDragEventHandlers(for: marker))
            """
    }
}

package func markerDragEventHandlers(for marker: MTMarker) -> String {
    """
        const postDragEvent\(marker.identifier) = (eventName) => {
            var markerCoord = \(marker.identifier).getLngLat();
            var data = {
                id: '\(marker.identifier)',
                lngLat: markerCoord
            };

            if (eventName === 'dragstart') {
                window.webkit.messageHandlers.mapHandler.postMessage({
                    event: 'dragstart',
                    data: data
                });
            } else if (eventName === 'dragend') {
                window.webkit.messageHandlers.mapHandler.postMessage({
                    event: 'dragend',
                    data: data
                });
            } else {
                window.webkit.messageHandlers.mapHandler.postMessage({
                    event: eventName,
                    data: data
                });
            }
        };

        \(marker.identifier).on('drag', () => postDragEvent\(marker.identifier)('drag'));
        \(marker.identifier).on('dragstart', () => postDragEvent\(marker.identifier)('dragstart'));
        \(marker.identifier).on('dragend', () => postDragEvent\(marker.identifier)('dragend'));
    """
}
