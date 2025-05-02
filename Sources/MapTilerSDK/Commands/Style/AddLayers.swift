//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddLayers.swift
//  MapTilerSDK
//

package struct AddLayers: MTCommand {
    let emptyReturnValue = ""

    var layers: [MTLayer]

    package func toJS() -> JSString {
        var jsString = ""

        for layer in layers {
            jsString.append("\n")

            if let layer = layer as? MTFillLayer {
                jsString.append(handleMTFillLayer(layer))
            } else if let layer = layer as? MTSymbolLayer {
                jsString.append(handleMTSymbolLayer(layer))
            } else if let layer = layer as? MTLineLayer {
                jsString.append(handleMTLineLayer(layer))
            }
        }

        return jsString
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
