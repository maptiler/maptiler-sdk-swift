//
//  PanTo.swift
//  MapTilerSDK
//
import CoreLocation

package struct PanTo: MTCommand {
    var coordinates: CLLocationCoordinate2D

    package func toJS() -> JSString {
        let lngLat = coordinates.toLngLat()

        return "\(MTBridge.mapObject).panTo([\(lngLat.lng), \(lngLat.lat)]);"
    }
}
