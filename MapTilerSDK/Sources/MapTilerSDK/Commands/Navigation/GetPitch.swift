//
//  GetPitch.swift
//  MapTilerSDK
//

package struct GetPitch: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getPitch();"
    }
}
