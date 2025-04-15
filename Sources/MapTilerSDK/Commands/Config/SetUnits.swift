//
//  SetUnits.swift
//  MapTilerSDK
//

package struct SetUnits: MTCommand {
    var unit: MTUnit

    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).config.units = \(unit.rawValue);"
    }
}
