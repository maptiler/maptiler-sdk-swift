import Foundation

package struct SetShowPadding: MTCommand {
    var show: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).showPadding = \(show);"
    }
}
