//
//  SetShouldRenderWorldCopies.swift
//  MapTilerSDK
//

package struct SetShouldRenderWorldCopies: MTCommand {
    var shouldRenderWorldCopies: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setRenderWorldCopies(\(shouldRenderWorldCopies));"
    }
}
