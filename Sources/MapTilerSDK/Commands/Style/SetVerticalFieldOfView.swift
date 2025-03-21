//
//  SetVerticalFieldOfView.swift
//  MapTilerSDK
//

package struct SetVerticalFieldOfView: MTCommand {
    var degrees: Double = 36.87

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setVerticalFieldOfView(\(degrees));"
    }
}
