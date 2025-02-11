//
//  PinchRotateAndZoomDisable.swift
//  MapTilerSDK
//

package struct PinchRotateAndZoomDisable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).touchZoomRotate.disable();"
    }
}
