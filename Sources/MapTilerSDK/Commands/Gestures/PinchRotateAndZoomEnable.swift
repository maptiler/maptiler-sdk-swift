//
//  TouchZoomRotateEnable.swift
//  MapTilerSDK
//

package struct PinchRotateAndZoomEnable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).touchZoomRotate.enable();"
    }
}
