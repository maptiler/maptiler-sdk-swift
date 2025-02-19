//
//  TwoFingersDrapPitchEnable.swift
//  MapTilerSDK
//

package struct TwoFingersDragPitchEnable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).touchPitch.enable();"
    }
}
