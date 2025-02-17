//
//  SetCenterClampedToGround.swift
//  MapTilerSDK
//

package struct SetCenterClampedToGround: MTCommand {
    var isCenterClampedToGround: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.shared.mapObject).setCenterClampedToGround(\(isCenterClampedToGround));"
    }
}
