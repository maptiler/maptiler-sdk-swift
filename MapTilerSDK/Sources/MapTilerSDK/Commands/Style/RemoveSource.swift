//
//  RemoveSource.swift
//  MapTilerSDK
//

package struct RemoveSource: MTCommand {
    var source: MTSource

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).removeSource('\(source.identifier)');"
    }
}
