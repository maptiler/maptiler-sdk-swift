//
//  AddLogoControl.swift
//  MapTilerSDK
//

import Foundation

package struct AddLogoControl: MTCommand {
    var url: URL
    var linkURL: URL
    var position: MTMapCorner

    package func toJS() -> JSString {
        let addLogoCommand = """
            const logo = new maptilersdk.MaptilerLogoControl({
                logoURL: "\(url)",
                linkURL: "\(linkURL)"
            });
            \("\(MTBridge.mapObject).addControl(logo, '\(position.rawValue)');")
            """

        return addLogoCommand
    }
}
