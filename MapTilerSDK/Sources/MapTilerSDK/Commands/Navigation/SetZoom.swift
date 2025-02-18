//
//  SetZoom.swift
//  MapTilerSDK
//

package struct SetZoom: MTCommand {
    var zoom: Double

    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).setZoom(\(zoom));"
    }
}
