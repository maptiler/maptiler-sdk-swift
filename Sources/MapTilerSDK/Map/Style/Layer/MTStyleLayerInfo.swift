//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTStyleLayerInfo.swift
//  MapTilerSDK
//

import Foundation

/// Read-only snapshot of a layer in the current map style.
///
/// Covers every layer of the style (including the built-in MapTiler layers), not only layers added through the SDK.
public struct MTStyleLayerInfo: Sendable, Equatable {
    /// Unique layer identifier.
    public let id: String

    /// Layer type, or `nil` if the type is not known to the SDK (see ``rawType``).
    public let type: MTLayerType?

    /// Layer type as reported by the style (e.g. `fill`, `line`).
    public let rawType: String

    /// Identifier of the source the layer reads from, if any.
    public let source: String?

    /// Vector tile layer name (e.g. `water`, `landcover`), if any.
    public let sourceLayer: String?

    /// Whether the layer's `visibility` layout property is `visible`.
    public let isVisible: Bool

    /// Minimum zoom level at which the layer is rendered, if set.
    public let minZoom: Double?

    /// Maximum zoom level at which the layer is rendered, if set.
    public let maxZoom: Double?

    public init(
        id: String,
        type: MTLayerType?,
        rawType: String,
        source: String?,
        sourceLayer: String?,
        isVisible: Bool,
        minZoom: Double?,
        maxZoom: Double?
    ) {
        self.id = id
        self.type = type
        self.rawType = rawType
        self.source = source
        self.sourceLayer = sourceLayer
        self.isVisible = isVisible
        self.minZoom = minZoom
        self.maxZoom = maxZoom
    }
}

/// Bridge payload for ``MTStyleLayerInfo``.
package struct MTStyleLayerInfoPayload: Decodable {
    let id: String
    let type: String
    let source: String?
    let sourceLayer: String?
    let visibility: String?
    let minzoom: Double?
    let maxzoom: Double?

    package var info: MTStyleLayerInfo {
        MTStyleLayerInfo(
            id: id,
            type: MTLayerType(rawValue: type),
            rawType: type,
            source: source,
            sourceLayer: sourceLayer,
            isVisible: visibility != "none",
            minZoom: minzoom,
            maxZoom: maxzoom
        )
    }

    /// Decodes the JSON array returned by ``GetStyleLayers``.
    package static func decodeList(from json: String) -> [MTStyleLayerInfo] {
        guard let data = json.data(using: .utf8) else { return [] }

        let payloads = try? JSONDecoder().decode([MTStyleLayerInfoPayload].self, from: data)
        return payloads?.map(\.info) ?? []
    }
}
