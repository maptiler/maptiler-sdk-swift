//
//  IsMapLoaded.swift
//  MapTilerSDK
//

package struct IsMapLoaded: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).loaded();"
    }
}
