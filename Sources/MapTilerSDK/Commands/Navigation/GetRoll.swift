//
//  GetRoll.swift
//  MapTilerSDK
//

package struct GetRoll: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getRoll();"
    }
}
