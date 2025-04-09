//
//  IsSourceLoaded.swift
//  MapTilerSDK
//

package struct IsSourceLoaded: MTCommand {
    var sourceId: String

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).isSourceLoaded('\(sourceId)');"
    }
}
