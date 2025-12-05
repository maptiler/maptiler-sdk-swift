//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddMarkers.swift
//  MapTilerSDK
//

import UIKit

package struct AddMarkers: MTCommand {
    var markers: [MTMarker]
    var withSingleIcon: UIImage?

    package func toJS() -> JSString {
        if markers.count == 0 {
            return ""
        }

        if let markerIcon = withSingleIcon {
            return handleMarkersWithSingleIcon(markerIcon: markerIcon, markers: markers)
        } else {
            return handleMarkers(markers: markers)
        }
    }

    package func handleMarkersWithSingleIcon(markerIcon: UIImage, markers: [MTMarker]) -> String {
        var iconInit = ""

        if let encodedImageString = markerIcon.getEncodedString() {
            iconInit = """
            var icon\(markers[0].identifier) = new Image();
            icon\(markers[0].identifier).src = 'data:image/png;base64,\(encodedImageString)';
        """

            var jsString = "\(iconInit)"
            jsString.append("\n")

            for marker in markers {
                let markerJS = """
                    var img\(marker.identifier) = document.createElement('img');
                    img\(marker.identifier).src = icon\(markers[0].identifier).src;
                    img\(marker.identifier).style.width = '\(markerIcon.size.width * markerIcon.scale)px';
                    img\(marker.identifier).style.height = '\(markerIcon.size.height * markerIcon.scale)px';

                    const \(marker.identifier) = new maptilersdk.Marker({
                        color: '\(marker.color?.toHex() ?? UIColor.blue.toHex())',
                        draggable: \(marker.draggable ?? false),
                        anchor: '\(marker.anchor.rawValue)',
                        offset: [\(marker.offset), \(marker.offset)],
                        element: img\(marker.identifier)
                    });

                    \(marker.identifier)
                    .setLngLat([\(marker.coordinates.longitude), \(marker.coordinates.latitude)])
                    .addTo(\(MTBridge.mapObject));
            """
                jsString.append("\n")
                jsString.append(markerJS)
            }

            return jsString
        }

        return ""
    }

    package func handleMarkers(markers: [MTMarker]) -> String {
        var jsString = ""

        for marker in markers {
            guard let icon = marker.icon, let encodedImageString = icon.getEncodedString() else {
                return ""
            }

            let coordinates = marker.coordinates.toLngLat()

            jsString += """
        var icon\(marker.identifier) = new Image();
        icon\(marker.identifier).src = 'data:image/png;base64,\(encodedImageString)';

        const \(marker.identifier) = new maptilersdk.Marker({
            color: '\(marker.color?.toHex() ?? UIColor.blue.toHex())',
            draggable: \(marker.draggable ?? false),
            anchor: '\(marker.anchor.rawValue)',
            offset: [\(marker.offset), \(marker.offset)],
            element: icon\(marker.identifier)
        });

        \(marker.identifier)
        .setLngLat([\(coordinates.lng), \(coordinates.lat)])
        .addTo(\(MTBridge.mapObject));
        """
        }

        return jsString
    }
}
