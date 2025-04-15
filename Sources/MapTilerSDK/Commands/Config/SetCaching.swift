//
//  SetCaching.swift
//  MapTilerSDK
//

package struct SetCaching: MTCommand {
    var shouldCache: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).config.caching = \(shouldCache);"
    }
}
