//
//  GetIdForStyleVariant.swift
//  MapTilerSDK
//

package struct GetIdForStyleVariant: MTCommand {
    var styleVariant: MTMapStyleVariant

    package func toJS() -> JSString {
        let styleVariant = styleVariant.rawValue.uppercased()

        return "\(MTBridge.sdkObject).\(MTBridge.styleObject).\(styleVariant).getId();"
    }
}
