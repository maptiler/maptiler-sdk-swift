//
//  PanBy.swift
//  MapTilerSDK
//

package struct PanBy: MTCommand {
    var offset: MTPoint

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).panBy([\(offset.x), \(offset.y)]);"
    }
}
