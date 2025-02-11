//
//  TwoFingersDrapPitchEnable.swift
//  MapTilerSDK
//

package struct TwoFingersDragPitchEnable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).touchPitch.enable();"
    }
}
