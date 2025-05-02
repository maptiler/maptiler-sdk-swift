//
//  GetBearing.swift
//  MapTilerSDK
//

package struct GetBearing: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getBearing();"
    }
}
