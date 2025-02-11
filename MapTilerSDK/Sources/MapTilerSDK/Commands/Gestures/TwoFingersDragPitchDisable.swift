//
//  TwoFingersDragPitchDisable.swift
//  MapTilerSDK
//

package struct TwoFingersDragPitchDisable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).touchPitch.disable();"
    }
}
