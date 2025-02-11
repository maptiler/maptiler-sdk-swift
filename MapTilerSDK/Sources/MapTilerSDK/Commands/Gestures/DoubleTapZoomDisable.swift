//
//  DoubleTapZoomDisable.swift
//  MapTilerSDK
//

package struct DoubleTapZoomDisable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).doubleClickZoom.disable();"
    }
}
