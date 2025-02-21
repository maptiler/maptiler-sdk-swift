//
//  SetStyle.swift
//  MapTilerSDK
//

package struct SetStyle: MTCommand {
    var referenceStyle: MTMapReferenceStyle
    var styleVariant: MTMapStyleVariant?

    package func toJS() -> JSString {
        let referenceStyle = referenceStyle.rawValue.uppercased()
        let style = (styleVariant != nil) ? "\(referenceStyle).\(styleVariant!.rawValue.uppercased())" : referenceStyle

        return "\(MTBridge.mapObject).setStyle(maptilersdk.MapStyle.\(style));"
    }
}
