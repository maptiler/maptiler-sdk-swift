//
//  GetZoom.swift
//  MapTilerSDK
//

package struct GetZoom: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getZoom();"
    }
}
