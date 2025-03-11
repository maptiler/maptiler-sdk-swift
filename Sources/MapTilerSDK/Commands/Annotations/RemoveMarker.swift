//
//  RemoveMarker.swift
//  MapTilerSDK
//

package struct RemoveMarker: MTCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        return "\(marker.identifier).remove();"
    }
}
