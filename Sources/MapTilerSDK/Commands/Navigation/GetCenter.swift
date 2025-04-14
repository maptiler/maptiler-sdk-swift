//
//  GetCenter.swift
//  MapTilerSDK
//

package struct GetCenter: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getCenter();"
    }
}
