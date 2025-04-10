//
//  SetCoordinatesToPopup.swift
//  MapTilerSDK
//

package struct SetCoordinatesToTextPopup: MTCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        let coordinates = popup.coordinates.toLngLat()

        return "\(popup.identifier).setLngLat([\(coordinates.lng), \(coordinates.lat)]);"
    }
}
