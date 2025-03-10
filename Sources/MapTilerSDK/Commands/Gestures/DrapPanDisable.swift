//
//  DrapPanDisable.swift
//  MapTilerSDK
//

package struct DragPanDisable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).dragPan.disable();"
    }
}
