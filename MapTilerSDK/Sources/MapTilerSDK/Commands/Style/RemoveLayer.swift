//
//  RemoveLayer.swift
//  MapTilerSDK
//

package struct RemoveLayer: MTCommand {
    var layer: MTLayer

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).removeLayer('\(layer.identifier)');"
    }
}
