//
//  AddLayer.swift
//  MapTilerSDK
//

package struct AddLayer: MTCommand {
    let emptyReturnValue = ""

    var layer: MTLayer

    package func toJS() -> JSString {
        if let layer = layer as? MTFillLayer {
            return handleMTFillLayer(layer)
        }

        return emptyReturnValue
    }

    private func handleMTFillLayer(_ layer: MTFillLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }

        return "\(MTBridge.mapObject).addLayer(\(layerString));"
    }
}
