//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetStyleLayers.swift
//  MapTilerSDK
//

/// Returns a JSON snapshot of every layer in the current style, in rendering order.
///
/// Uses `getLayersOrder()` + `getLayer()` instead of `getStyle()` to avoid serializing sources and expressions.
package struct GetStyleLayers: MTValueCommand {
    package func toJS() -> JSString {
        return "JSON.stringify((function() {"
            + " var m = \(MTBridge.mapObject);"
            + " if (!m.getLayersOrder) { return []; }"
            + " return m.getLayersOrder().map(function(id) {"
            + " var l = m.getLayer(id);"
            + " if (!l) { return null; }"
            + " return {"
            + " id: l.id,"
            + " type: l.type,"
            + " source: l.source || null,"
            + " sourceLayer: l.sourceLayer || null,"
            + " visibility: m.getLayoutProperty(id, 'visibility') || 'visible',"
            + " minzoom: (typeof l.minzoom === 'number') ? l.minzoom : null,"
            + " maxzoom: (typeof l.maxzoom === 'number') ? l.maxzoom : null"
            + " };"
            + " }).filter(function(l) { return l !== null; });"
            + " })());"
    }
}
