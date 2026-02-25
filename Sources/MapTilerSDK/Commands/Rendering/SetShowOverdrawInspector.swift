import Foundation

package struct SetShowOverdrawInspector: MTCommand {
    var show: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).showOverdrawInspector = \(show);"
    }
}
