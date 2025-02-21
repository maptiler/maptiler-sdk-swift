//
//  SetMaxPitch.swift
//  MapTilerSDK
//

package struct SetMaxPitch: MTCommand {
    let defaultPitch: Double = 60.0

    var maxPitch: Double?

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setMaxPitch(\(maxPitch ?? defaultPitch));"
    }
}
