//
//  SetUrlToSource.swift
//  MapTilerSDK
//

import Foundation

package struct SetUrlToSource: MTCommand {
    var url: URL
    var source: MTSource

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getSource('\(source.identifier)').setUrl('\(url)');"
    }
}
