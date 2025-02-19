//
//  DragPanEnable.swift
//  MapTilerSDK
//

package struct DragPanEnable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).dragPan.enable();"
    }
}
