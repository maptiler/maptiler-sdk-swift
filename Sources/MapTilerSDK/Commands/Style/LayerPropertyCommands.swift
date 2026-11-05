//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  LayerPropertyCommands.swift
//  MapTilerSDK
//

import Foundation

/// Style property group a layer property belongs to.
package enum LayerPropertyKind: Sendable {
    case layout
    case paint

    var jsGetter: String {
        switch self {
        case .layout: return "getLayoutProperty"
        case .paint: return "getPaintProperty"
        }
    }

    var jsSetter: String {
        switch self {
        case .layout: return "setLayoutProperty"
        case .paint: return "setPaintProperty"
        }
    }
}

/// Encodes a value as a JSON literal
private func jsonLiteral<T: Encodable>(_ value: T) -> String {
    guard let data = try? JSONEncoder().encode(value), let string = String(data: data, encoding: .utf8) else {
        return "null"
    }
    return string
}

/// Returns the JSON encoded value of a layout or paint property, or `"null"` if the layer is missing
/// or the property is unset.
package struct GetLayerProperty: MTValueCommand {
    let layerId: String
    let name: String
    let kind: LayerPropertyKind

    package func toJS() -> JSString {
        let id = jsonLiteral(layerId)
        let property = jsonLiteral(name)

        return "JSON.stringify((function() {"
            + " var m = \(MTBridge.mapObject);"
            + " if (!m.getLayer(\(id))) { return null; }"
            + " var v = m.\(kind.jsGetter)(\(id), \(property));"
            + " return v === undefined ? null : v;"
            + " })());"
    }
}

/// Sets the same layout or paint property on many layers in a single bridge call. Missing layers are skipped.
package struct SetPropertyForLayers: MTCommand {
    let layerIds: [String]
    let name: String
    let value: MTPropertyValue
    let kind: LayerPropertyKind

    package func toJS() -> JSString {
        let ids = jsonLiteral(layerIds)
        let property = jsonLiteral(name)

        return "(function(ids, value) {"
            + " var m = \(MTBridge.mapObject);"
            + " ids.forEach(function(id) { if (m.getLayer(id)) { m.\(kind.jsSetter)(id, \(property), value); } });"
            + " })(\(ids), \(value.toJS()));"
    }
}
