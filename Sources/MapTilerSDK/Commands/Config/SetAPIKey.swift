//
//  SetAPIKey.swift
//  MapTilerSDK
//

package struct SetAPIKey: MTCommand {
    var apiKey: String

    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).config.apiKey = '\(apiKey)';"
    }
}
