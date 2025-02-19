//
//  TwoFingersDragPitchDisable.swift
//  MapTilerSDK
//

package struct TwoFingersDragPitchDisable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).touchPitch.disable();"
    }
}
