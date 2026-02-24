import Foundation

package struct SetShowCollisionBoxes: MTCommand {
    var show: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).showCollisionBoxes = \(show);"
    }
}
