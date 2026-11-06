//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLayerQuery.swift
//  MapTilerSDK
//

import Foundation

/// Describes which style layers to select.
///
/// Every non-nil criterion must match (AND). Within a single criterion any value may match (OR).
/// An empty query (all criteria `nil`) matches every layer.
///
/// Example: all line layers drawing water
/// ```swift
/// MTLayerQuery(types: [.line], categories: [.water])
/// ```
public struct MTLayerQuery: Sendable, Equatable {
    /// Exact layer identifiers.
    public var ids: Set<String>?

    /// Case-insensitive substring of the layer identifier.
    public var idContains: String?

    /// Layer types.
    public var types: Set<MTLayerType>?

    /// Source identifiers.
    public var sources: Set<String>?

    /// Vector tile source layer names (e.g. `water`, `road`).
    public var sourceLayers: Set<String>?

    /// Semantic layer categories, see ``MTLayerCategory``.
    public var categories: Set<MTLayerCategory>?

    public init(
        ids: Set<String>? = nil,
        idContains: String? = nil,
        types: Set<MTLayerType>? = nil,
        sources: Set<String>? = nil,
        sourceLayers: Set<String>? = nil,
        categories: Set<MTLayerCategory>? = nil
    ) {
        self.ids = ids
        self.idContains = idContains
        self.types = types
        self.sources = sources
        self.sourceLayers = sourceLayers
        self.categories = categories
    }

    /// Query matching every layer of the given categories.
    public static func of(_ categories: MTLayerCategory...) -> MTLayerQuery {
        MTLayerQuery(categories: Set(categories))
    }

    /// Returns whether `layer` satisfies this query.
    public func matches(_ layer: MTStyleLayerInfo) -> Bool {
        if let ids, !ids.contains(layer.id) { return false }
        if let idContains, !layer.id.localizedCaseInsensitiveContains(idContains) { return false }
        if let types, !(layer.type.map { types.contains($0) } ?? false) { return false }
        if let sources, !(layer.source.map { sources.contains($0) } ?? false) { return false }
        if let sourceLayers, !(layer.sourceLayer.map { sourceLayers.contains($0) } ?? false) { return false }
        if let categories, !categories.contains(where: { $0.matches(layer) }) { return false }
        return true
    }
}
