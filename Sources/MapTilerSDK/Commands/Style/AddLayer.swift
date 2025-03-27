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
        } else if let layer = layer as? MTSymbolLayer {
            return handleMTSymbolLayer(layer)
        } else if let layer = layer as? MTLineLayer {
            return handleMTLineLayer(layer)
        }

        return emptyReturnValue
    }

    private func handleMTFillLayer(_ layer: MTFillLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }

        return "\(MTBridge.mapObject).addLayer(\(layerString));"
    }

    private func handleMTSymbolLayer(_ layer: MTSymbolLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }

        var jsString = ""

        if let icon = layer.icon, let encodedImageString = icon.getEncodedString() {
            let iconString = """
            var icon\(layer.identifier) = new Image();
                icon\(layer.identifier).src = 'data:image/png;base64,\(encodedImageString)';
                icon\(layer.identifier).onload = function() {
                    map.addImage('icon\(layer.identifier)', icon\(layer.identifier))
        """
            jsString.append(iconString)
            jsString.append("\n ")
        }

        jsString.append("\(MTBridge.mapObject).addLayer(\(layerString))")
        jsString.append("\n };")

        return jsString
    }

    private func handleMTLineLayer(_ layer: MTLineLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }

        return "\(MTBridge.mapObject).addLayer(\(layerString));"
    }
}
