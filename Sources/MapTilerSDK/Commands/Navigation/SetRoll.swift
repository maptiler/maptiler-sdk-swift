//
//  SetRoll.swift
//  MapTilerSDK
//

package struct SetRoll: MTCommand {
    var roll: Double

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setRoll(\(roll));"
    }
}
