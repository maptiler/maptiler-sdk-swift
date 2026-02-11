//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
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
        } else if let layer = layer as? MTRasterLayer {
            return handleMTRasterLayer(layer)
        } else if let layer = layer as? MTHillshadeLayer {
            return handleMTHillshadeLayer(layer)
        } else if let layer = layer as? MTCircleLayer {
            return handleMTCircleLayer(layer)
        } else if let layer = layer as? MTHeatmapLayer {
            return handleMTHeatmapLayer(layer)
        } else if let layer = layer as? MTFillExtrusionLayer {
            return handleMTFillExtrusionLayer(layer)
        }

        return emptyReturnValue
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

        // If an icon is provided, load it and then add the layer inside onload callback.
        if let icon = layer.icon, let encodedImageString = icon.getEncodedString() {
            return """
            var icon\(layer.identifier) = new Image();
            icon\(layer.identifier).src = 'data:image/png;base64,\(encodedImageString)';
            icon\(layer.identifier).onload = function() {
                map.addImage('icon\(layer.identifier)', icon\(layer.identifier));
                \(MTBridge.mapObject).addLayer(\(unquoteExpressions(in: layerString)));
            };
            """
        } else {
            // No icon: just add the layer.
            return "\(MTBridge.mapObject).addLayer(\(unquoteExpressions(in: layerString)));"
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

        return "\(MTBridge.mapObject).addLayer(\(unquoteExpressions(in: layerString)));"
    }

    private func handleMTHillshadeLayer(_ layer: MTHillshadeLayer) -> JSString {
        guard let layerString: JSString = layer.toJSON() else {
            return emptyReturnValue
        }

        return "\(MTBridge.mapObject).addLayer(\(unquoteExpressions(in: layerString)));"
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
    // Unescape escaped quotes inside expression arrays (e.g., \"step\" -> "step")
    s = s.replacingOccurrences(of: "\\\"", with: "\"")
    return s
}
