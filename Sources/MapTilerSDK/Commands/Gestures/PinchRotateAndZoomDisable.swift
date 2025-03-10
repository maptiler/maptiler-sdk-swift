//
//  PinchRotateAndZoomDisable.swift
//  MapTilerSDK
//

package struct PinchRotateAndZoomDisable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).touchZoomRotate.disable();"
    }
}
