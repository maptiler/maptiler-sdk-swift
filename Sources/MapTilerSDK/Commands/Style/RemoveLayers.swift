//
//  RemoveLayers.swift
//  MapTilerSDK
//

package struct RemoveLayers: MTCommand {
    var layers: [MTLayer]

    package func toJS() -> JSString {
        var jsString = ""

        for layer in layers {
            jsString.append("\(MTBridge.mapObject).removeLayer('\(layer.identifier)');")
        }

        return jsString
    }
}
