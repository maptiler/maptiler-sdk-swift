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
            } else if let layer = layer as? MTRasterLayer {
                jsString.append(handleMTRasterLayer(layer))
            } else if let layer = layer as? MTHillshadeLayer {
                jsString.append(handleMTHillshadeLayer(layer))
            } else if let layer = layer as? MTCircleLayer {
                jsString.append(handleMTCircleLayer(layer))
            } else if let layer = layer as? MTHeatmapLayer {
                jsString.append(handleMTHeatmapLayer(layer))
            } else if let layer = layer as? MTFillExtrusionLayer {
                jsString.append(handleMTFillExtrusionLayer(layer))
            } else if let layer = layer as? MTBackgroundLayer {
                jsString.append(handleMTBackgroundLayer(layer))
            }
        }

        return jsString
    }

    private func handleMTFillLayer(_ layer: MTFillLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }
        let processed = unquoteExpressions(in: layerString)
        var js = "\(MTBridge.mapObject).addLayer(\(processed));"
        if let filter = layer.initialFilter {
            js.append("\n \(MTBridge.mapObject).setFilter('\(layer.identifier)', \(filter.toJS()));")
        }

        return js
    }

    private func handleMTSymbolLayer(_ layer: MTSymbolLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }

        if let icon = layer.icon, let encodedImageString = icon.getEncodedString() {
            return """
            var icon\(layer.identifier) = new Image();
            icon\(layer.identifier).src = 'data:image/png;base64,\(encodedImageString)';
            icon\(layer.identifier).onload = function() {
                map.addImage('icon\(layer.identifier)', icon\(layer.identifier));
                \(MTBridge.mapObject).addLayer(\(layerString));
            };
            """
        } else {
            return "\(MTBridge.mapObject).addLayer(\(layerString));"
        }
    }

    private func handleMTLineLayer(_ layer: MTLineLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }
        let processed = unquoteExpressions(in: layerString)
        var js = "\(MTBridge.mapObject).addLayer(\(processed));"
        if let filter = layer.initialFilter {
            js.append("\n \(MTBridge.mapObject).setFilter('\(layer.identifier)', \(filter.toJS()));")
        }
        return js
    }

    private func handleMTRasterLayer(_ layer: MTRasterLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }

        return "\(MTBridge.mapObject).addLayer(\(layerString));"
    }

    private func handleMTHillshadeLayer(_ layer: MTHillshadeLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }

        return "\(MTBridge.mapObject).addLayer(\(layerString));"
    }

    private func handleMTCircleLayer(_ layer: MTCircleLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }
        let processed = unquoteExpressions(in: layerString)
        var js = "\(MTBridge.mapObject).addLayer(\(processed));"
        if let filter = layer.initialFilter {
            js.append("\n \(MTBridge.mapObject).setFilter('\(layer.identifier)', \(filter.toJS()));")
        }
        return js
    }

    private func handleMTHeatmapLayer(_ layer: MTHeatmapLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }
        let processed = unquoteExpressions(in: layerString)
        var js = "\(MTBridge.mapObject).addLayer(\(processed));"
        if let filter = layer.initialFilter {
            js.append("\n \(MTBridge.mapObject).setFilter('\(layer.identifier)', \(filter.toJS()));")
        }
        return js
    }

    private func handleMTFillExtrusionLayer(_ layer: MTFillExtrusionLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }
        let processed = unquoteExpressions(in: layerString)
        var js = "\(MTBridge.mapObject).addLayer(\(processed));"
        if let filter = layer.initialFilter {
            js.append("\n \(MTBridge.mapObject).setFilter('\(layer.identifier)', \(filter.toJS()));")
        }
        return js
    }

    private func handleMTBackgroundLayer(_ layer: MTBackgroundLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }
        let processed = unquoteExpressions(in: layerString)
        return "\(MTBridge.mapObject).addLayer(\(processed));"
    }
}

/// Replaces string-encoded expressions with raw JSON arrays.
/// Ensures the style parser reads them as expressions (not strings).
fileprivate func unquoteExpressions(in json: String) -> String {
    var s = json
    s = s.replacingOccurrences(
        of: #"(?s)("filter"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("circle-color"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("circle-radius"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("heatmap-color"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("heatmap-radius"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("heatmap-intensity"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("heatmap-opacity"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("heatmap-weight"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("fill-extrusion-color"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("fill-extrusion-height"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("fill-extrusion-base"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("fill-extrusion-opacity"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(
        of: #"(?s)("background-color"\s*:\s*)"(\[.*?\])""#,
        with: "$1$2",
        options: .regularExpression
    )
    s = s.replacingOccurrences(of: "\\\"", with: "\"")
    return s
}
