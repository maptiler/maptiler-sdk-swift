//
//  EnableGlobeProjection.swift
//  MapTilerSDK
//

package struct EnableGlobeProjection: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).enableGlobeProjection();"
    }
}
