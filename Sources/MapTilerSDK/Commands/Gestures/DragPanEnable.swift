//
//  DragPanEnable.swift
//  MapTilerSDK
//

package struct DragPanEnable: MTCommand {
    var options: MTDragPanOptions?

    package func toJS() -> JSString {
        let optionsString: JSString = options?.toJSON() ?? ""

        return "\(MTBridge.mapObject).dragPan.enable(\(optionsString));"
    }
}
