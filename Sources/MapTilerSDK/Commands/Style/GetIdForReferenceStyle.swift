//
//  GetIdForReferenceStyle.swift
//  MapTilerSDK
//

package struct GetIdForReferenceStyle: MTCommand {
    var referenceStyle: MTMapReferenceStyle

    package func toJS() -> JSString {
        let referenceStyle = referenceStyle.rawValue.uppercased()

        return "\(MTBridge.sdkObject).\(MTBridge.styleObject).\(referenceStyle).getId();"
    }
}
