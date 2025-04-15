//
//  SetTelemetry.swift
//  MapTilerSDK
//

package struct SetTelemetry: MTCommand {
    var shouldEnableTelemetry: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).config.telemetry = \(shouldEnableTelemetry);"
    }
}
