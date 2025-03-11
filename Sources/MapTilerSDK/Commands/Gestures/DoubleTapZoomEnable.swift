//
//  DoubleTapZoomEnable.swift
//  MapTilerSDK
//

package struct DoubleTapZoomEnable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).doubleClickZoom.enable();"
    }
}
