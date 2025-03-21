//
//  EnableTerrain.swift
//  MapTilerSDK
//

package struct EnableTerrain: MTCommand {
    var exaggerationFactor: Double = 1.0

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).enableTerrain(\(exaggerationFactor));"
    }
}
