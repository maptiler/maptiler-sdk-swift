//
//  SetTilesToSource.swift
//  MapTilerSDK
//

import Foundation

package struct SetTilesToSource: MTCommand {
    var tiles: [URL]
    var source: MTSource

    package func toJS() -> JSString {
        let tiles = "\(tiles.map { $0.absoluteString.removingPercentEncoding ?? "" })"
        return "\(MTBridge.mapObject).getSource('\(source.identifier)').setTiles(\(tiles);"
    }
}
