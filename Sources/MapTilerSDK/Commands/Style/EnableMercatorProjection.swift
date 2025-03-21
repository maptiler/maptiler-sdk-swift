//
//  EnableMercatorProjection.swift
//  MapTilerSDK
//

package struct EnableMercatorProjection: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).enableMercatorProjection();"
    }
}
