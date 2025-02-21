//
//  SetMinPitch.swift
//  MapTilerSDK
//

package struct SetMinPitch: MTCommand {
    let defaultPitch: Double = 0.0

    var minPitch: Double?

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setMinPitch(\(minPitch ?? defaultPitch));"
    }
}
