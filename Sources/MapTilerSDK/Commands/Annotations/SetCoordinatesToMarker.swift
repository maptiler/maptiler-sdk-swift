//
//  SetCoordinatesToMarker.swift
//  MapTilerSDK
//

package struct SetCoordinatesToMarker: MTCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        let coordinates = marker.coordinates.toLngLat()

        return "\(marker.identifier).setLngLat([\(coordinates.lng), \(coordinates.lat)]);"
    }
}
