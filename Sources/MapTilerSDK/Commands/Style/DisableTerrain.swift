//
//  DisableTerrain.swift
//  MapTilerSDK
//

package struct DisableTerrain: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).disableTerrain();"
    }
}
