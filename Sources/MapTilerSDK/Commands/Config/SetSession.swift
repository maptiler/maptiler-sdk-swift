//
//  SetSession.swift
//  MapTilerSDK
//

package struct SetSession: MTCommand {
    var shouldEnableSessionLogic: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).config.session = \(shouldEnableSessionLogic);"
    }
}
