//
//  SetRoll.swift
//  MapTilerSDK
//

package struct SetRoll: MTCommand {
    var roll: Double

    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).setRoll(\(roll));"
    }
}
