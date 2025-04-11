//
//  InitializeMap.swift
//  MapTilerSDK
//

package struct InitializeMap: MTCommand {
    var apiKey: String
    var options: MTMapOptions?
    var referenceStyle: MTMapReferenceStyle
    var styleVariant: MTMapStyleVariant?

    package func toJS() -> JSString {
        let referenceStyleName = referenceStyle.getName()

        var styleString = ""

        if referenceStyle.isCustom() {
            styleString = "'\(referenceStyleName)'"
        } else {
            let style = (
                styleVariant != nil
            ) ? "\(referenceStyleName).\(styleVariant!.rawValue.uppercased())" : referenceStyleName

            styleString = "\(MTBridge.sdkObject).\(MTBridge.styleObject).\(style)"
        }

        var optionsString: JSString = options?.toJSON() ?? ""

        // Replace language string to match maptilersdk specific language format
        if case .special = options?.language {
            let patternToReplace = #"("language":\s*)"([^"]*)""#
            optionsString = optionsString.replacingOccurrences(
                of: patternToReplace,
                with: #"$1$2"#,
                options: .regularExpression
            )
        }

        return "initializeMap('\(apiKey)', \(styleString), \(optionsString));"
    }
}
