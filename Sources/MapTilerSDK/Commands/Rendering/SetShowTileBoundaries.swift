import Foundation

package struct SetShowTileBoundaries: MTCommand {
    var show: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).showTileBoundaries = \(show);"
    }
}
