//
//  MoveLayer.swift
//  MapTilerSDK
//

package struct MoveLayer: MTCommand {
    var id: String
    var beforeId: String?

    package func toJS() -> JSString {
        let idString = id.toJSON() ?? "\"\(id)\""
        if let beforeId = beforeId {
            let beforeIdString = beforeId.toJSON() ?? "\"\(beforeId)\""
            return "\(MTBridge.mapObject).moveLayer(\(idString), \(beforeIdString));"
        } else {
            return "\(MTBridge.mapObject).moveLayer(\(idString));"
        }
    }
}
