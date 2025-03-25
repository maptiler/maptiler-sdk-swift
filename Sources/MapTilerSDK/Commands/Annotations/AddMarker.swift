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

        if let icon = marker.icon, let encodedImageString = icon.getEncodedString() {
            iconInit = """
            var icon\(marker.identifier) = new Image();
            icon\(marker.identifier).src = 'data:image/png;base64,\(encodedImageString)';
        """

            iconData = "element: icon\(marker.identifier)"
        }

        return """
            \(iconInit)

            const \(marker.identifier) = new maptilersdk.Marker({
                color: '\(marker.color?.toHex() ?? UIColor.blue.toHex())',
                draggable: \(marker.draggable ?? false),
                \(iconData)
            });

            \(marker.identifier)
            .setLngLat([\(coordinates.lng), \(coordinates.lat)])
            .addTo(\(MTBridge.mapObject));
            """
    }
}
