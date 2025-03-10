//
//  AddMarker.swift
//  MapTilerSDK
//

import UIKit

package struct AddMarker: MTCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        let coordinates = marker.coordinates.toLngLat()

        return """
            const \(marker.identifier) = new maptilersdk.Marker({
                color: '\(marker.color?.toHex() ?? UIColor.blue.toHex())',
                draggable: \(marker.draggable ?? false)
            });
            
            \(marker.identifier)
            .setLngLat([\(coordinates.lng), \(coordinates.lat)])
            .addTo(\(MTBridge.mapObject));
            """
    }
}
