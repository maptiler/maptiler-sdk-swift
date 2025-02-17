//
//  SetLight.swift
//  MapTilerSDK
//

package struct SetLight: MTCommand {
    var light: MTLight
    var options: MTStyleSetterOptions?

    package func toJS() -> JSString {
        let lightString: JSString = light.toJSON() ?? ""
        let parameters: JSString = options != nil ? "\(lightString),\(options.toJSON() ?? "")" : lightString

        return "\(MTBridge.shared.mapObject).setLight(\(parameters));"
    }
}
