//
//  SetGlyphs.swift
//  MapTilerSDK
//

import Foundation

package struct SetGlyphs: MTCommand {
    var url: URL
    var options: MTStyleSetterOptions?

    package func toJS() -> JSString {
        let absoluteURLString = url.absoluteString
        let parameters: JSString = options != nil ? "\(absoluteURLString),\(options.toJSON() ?? "")" : absoluteURLString

        return "\(MTBridge.mapObject).setGlyphs(\(parameters));"
    }
}
