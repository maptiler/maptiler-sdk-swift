//
//  RemoveTextPopup.swift
//  MapTilerSDK
//

package struct RemoveTextPopup: MTCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        return "\(popup.identifier).remove();"
    }
}
