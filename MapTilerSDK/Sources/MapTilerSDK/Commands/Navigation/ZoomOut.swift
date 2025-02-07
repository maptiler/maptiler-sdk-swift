//
//  ZoomOut.swift
//  MapTilerSDK
//

package struct ZoomOut: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).zoomOut()"
    }
}
