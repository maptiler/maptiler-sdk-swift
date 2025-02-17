//
//  SetMinZoom.swift
//  MapTilerSDK
//

package struct SetMinZoom: MTCommand {
    let defaultZoom: Double = -2.0

    var minZoom: Double?

    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).setMinZoom(\(minZoom ?? defaultZoom));"
    }
}
