//
//  SetMaxZoom.swift
//  MapTilerSDK
//

package struct SetMaxZoom: MTCommand {
    let defaultZoom: Double = 22.0

    var maxZoom: Double?

    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).setMaxZoom(\(maxZoom ?? defaultZoom));"
    }
}
