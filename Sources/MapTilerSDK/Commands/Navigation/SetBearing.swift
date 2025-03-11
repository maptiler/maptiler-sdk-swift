//
//  SetBearing.swift
//  MapTilerSDK
//

package struct SetBearing: MTCommand {
    var bearing: Double

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setBearing(\(bearing));"
    }
}
