//
//  SetPitch.swift
//  MapTilerSDK
//

package struct SetPitch: MTCommand {
    var pitch: Double

    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).setPitch(\(pitch));"
    }
}
