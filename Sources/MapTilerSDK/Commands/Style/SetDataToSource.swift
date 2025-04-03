//
//  SetDataToSource.swift
//  MapTilerSDK
//

import Foundation

package struct SetDataToSource: MTCommand {
    var data: URL
    var source: MTSource

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getSource('\(source.identifier)').setData('\(data)');"
    }
}
