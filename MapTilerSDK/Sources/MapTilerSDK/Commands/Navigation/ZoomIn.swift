//
//  ZoomIn.swift
//  MapTilerSDK
//

package struct ZoomIn: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).zoomIn()"
    }
}
