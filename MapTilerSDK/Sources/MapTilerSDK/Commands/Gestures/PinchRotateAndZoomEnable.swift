//
//  TouchZoomRotateEnable.swift
//  MapTilerSDK
//

package struct PinchRotateAndZoomEnable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).touchZoomRotate.enable();"
    }
}
