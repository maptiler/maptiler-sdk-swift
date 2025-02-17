//
//  SetCenterElevation.swift
//  MapTilerSDK
//

package struct SetCenterElevation: MTCommand {
    var elevation: Double

    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).setCenterElevation(\(elevation));"
    }
}
