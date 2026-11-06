//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTStyle+LayerQuery.swift
//  MapTilerSDK
//

import Foundation

// MARK: - Layer queries
extension MTStyle {
    /// Returns the layers of the current style in rendering order, including the built-in MapTiler style layers.
    ///
    /// The result is a fresh snapshot each call; it reflects style changes and visibility toggles.
    /// - Parameter query: Optional filter. When `nil`, all layers are returned.
    public func getStyleLayers(matching query: MTLayerQuery? = nil) async throws -> [MTStyleLayerInfo] {
        let result = try await mapView.execute(command: GetStyleLayers())
        guard case .string(let json) = result else { return [] }

        let layers = MTStyleLayerInfoPayload.decodeList(from: json)
        guard let query else { return layers }
        return layers.filter { query.matches($0) }
    }

    /// Returns the value of a layout property decoded with `JSONSerialization` (`String`, `NSNumber`, `[Any]`, ...),
    /// or `nil` if the layer does not exist or the property is unset.
    public func getLayoutProperty(layerId: String, name: String) async throws -> Any? {
        try await getLayerProperty(layerId: layerId, name: name, kind: .layout)
    }

    /// Returns the value of a paint property decoded with `JSONSerialization` (`String`, `NSNumber`, `[Any]`, ...),
    /// or `nil` if the layer does not exist or the property is unset.
    public func getPaintProperty(layerId: String, name: String) async throws -> Any? {
        try await getLayerProperty(layerId: layerId, name: name, kind: .paint)
    }

    /// Sets a layout property on every layer matching `query` in a single bridge call.
    /// - Returns: Identifiers of the affected layers.
    @discardableResult
    public func setLayoutProperty(
        _ name: String,
        value: MTPropertyValue,
        matching query: MTLayerQuery
    ) async throws -> [String] {
        let ids = try await getStyleLayers(matching: query).map(\.id)
        try await setProperty(name, value: value, kind: .layout, layerIds: ids)
        return ids
    }

    /// Sets a paint property on every layer matching `query` in a single bridge call.
    /// - Returns: Identifiers of the affected layers.
    @discardableResult
    public func setPaintProperty(
        _ name: String,
        value: MTPropertyValue,
        matching query: MTLayerQuery
    ) async throws -> [String] {
        let ids = try await getStyleLayers(matching: query).map(\.id)
        try await setProperty(name, value: value, kind: .paint, layerIds: ids)
        return ids
    }

    /// Shows or hides every layer matching `query`.
    ///
    /// Visibility is part of the style, so it is reset when the style changes.
    /// - Returns: Identifiers of the affected layers.
    @discardableResult
    public func setVisibility(_ visible: Bool, matching query: MTLayerQuery) async throws -> [String] {
        try await setLayoutProperty(Self.visibility, value: Self.visibilityValue(visible), matching: query)
    }

    /// Shows or hides every layer of the given category in the current style.
    /// - Returns: Identifiers of the affected layers.
    @discardableResult
    public func setVisibility(_ visible: Bool, for category: MTLayerCategory) async throws -> [String] {
        try await setVisibility(visible, matching: .of(category))
    }

    /// Toggles the layers matching `query`: hides them all if any is visible, otherwise shows them all.
    /// - Returns: The new visibility, or `nil` if no layer matched.
    @discardableResult
    public func toggleVisibility(matching query: MTLayerQuery) async throws -> Bool? {
        let layers = try await getStyleLayers(matching: query)
        guard !layers.isEmpty else { return nil }

        let visible = !layers.contains { $0.isVisible }
        try await setProperty(
            Self.visibility,
            value: Self.visibilityValue(visible),
            kind: .layout,
            layerIds: layers.map(\.id)
        )
        return visible
    }

    /// Toggles every layer of the given category. See ``toggleVisibility(matching:)``.
    @discardableResult
    public func toggleVisibility(for category: MTLayerCategory) async throws -> Bool? {
        try await toggleVisibility(matching: .of(category))
    }

    /// Builds legend entries for the given categories, skipping categories with no layers in the current style.
    ///
    /// Each entry carries the layer ids (for toggling), the current visibility and a representative color taken
    /// from the style's paint properties.
    /// - Parameter categories: Categories to include, in the order they should appear.
    public func getLegend(for categories: [MTLayerCategory] = MTLayerCategory.allCases) async throws -> [MTLegendItem] {
        let layers = try await getStyleLayers()
        var items: [MTLegendItem] = []

        for category in categories {
            let matching = layers.filter { category.matches($0) }
            guard !matching.isEmpty else { continue }

            var color: String?
            if let swatch = MTLegendColorResolver.swatchSource(for: category, in: matching) {
                let value = try await getPaintProperty(layerId: swatch.layer.id, name: swatch.property)
                color = MTLegendColorResolver.firstColor(in: value)
            }

            items.append(
                MTLegendItem(
                    category: category,
                    name: category.defaultName,
                    layerIds: matching.map(\.id),
                    isVisible: matching.contains { $0.isVisible },
                    color: color
                )
            )
        }
        return items
    }

    // MARK: - Private

    private static let visibility = "visibility"

    private static func visibilityValue(_ visible: Bool) -> MTPropertyValue {
        .string(visible ? "visible" : "none")
    }

    private func getLayerProperty(layerId: String, name: String, kind: LayerPropertyKind) async throws -> Any? {
        let result = try await mapView.execute(command: GetLayerProperty(layerId: layerId, name: name, kind: kind))
        guard case .string(let json) = result, let data = json.data(using: .utf8) else { return nil }

        let value = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        return value is NSNull ? nil : value
    }

    private func setProperty(
        _ name: String,
        value: MTPropertyValue,
        kind: LayerPropertyKind,
        layerIds: [String]
    ) async throws {
        guard !layerIds.isEmpty else { return }
        _ = try await mapView.execute(
            command: SetPropertyForLayers(layerIds: layerIds, name: name, value: value, kind: kind)
        )
    }
}

// MARK: - Layer queries (completion handlers)
extension MTStyle {
    /// Returns the layers of the current style in rendering order, including the built-in MapTiler style layers.
    /// - Parameters:
    ///   - query: Optional filter. When `nil`, all layers are returned.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getStyleLayers(
        matching query: MTLayerQuery? = nil,
        completionHandler: ((Result<[MTStyleLayerInfo], MTError>) -> Void)?
    ) {
        deliver(completionHandler) { try await self.getStyleLayers(matching: query) }
    }

    /// Returns the value of a layout property, or `nil` if the layer does not exist or the property is unset.
    /// - Parameters:
    ///   - layerId: Target layer identifier.
    ///   - name: Layout property name.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getLayoutProperty(
        layerId: String,
        name: String,
        completionHandler: ((Result<Any?, MTError>) -> Void)?
    ) {
        deliver(completionHandler) { try await self.getLayoutProperty(layerId: layerId, name: name) }
    }

    /// Returns the value of a paint property, or `nil` if the layer does not exist or the property is unset.
    /// - Parameters:
    ///   - layerId: Target layer identifier.
    ///   - name: Paint property name.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getPaintProperty(
        layerId: String,
        name: String,
        completionHandler: ((Result<Any?, MTError>) -> Void)?
    ) {
        deliver(completionHandler) { try await self.getPaintProperty(layerId: layerId, name: name) }
    }

    /// Sets a layout property on every layer matching `query` in a single bridge call.
    /// - Parameters:
    ///   - name: Layout property name.
    ///   - value: Property value or expression.
    ///   - query: Layers to update.
    ///   - completionHandler: A handler block receiving the identifiers of the affected layers.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setLayoutProperty(
        _ name: String,
        value: MTPropertyValue,
        matching query: MTLayerQuery,
        completionHandler: ((Result<[String], MTError>) -> Void)? = nil
    ) {
        deliver(completionHandler) { try await self.setLayoutProperty(name, value: value, matching: query) }
    }

    /// Sets a paint property on every layer matching `query` in a single bridge call.
    /// - Parameters:
    ///   - name: Paint property name.
    ///   - value: Property value or expression.
    ///   - query: Layers to update.
    ///   - completionHandler: A handler block receiving the identifiers of the affected layers.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setPaintProperty(
        _ name: String,
        value: MTPropertyValue,
        matching query: MTLayerQuery,
        completionHandler: ((Result<[String], MTError>) -> Void)? = nil
    ) {
        deliver(completionHandler) { try await self.setPaintProperty(name, value: value, matching: query) }
    }

    /// Shows or hides every layer matching `query`.
    /// - Parameters:
    ///   - visible: Desired visibility.
    ///   - query: Layers to update.
    ///   - completionHandler: A handler block receiving the identifiers of the affected layers.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setVisibility(
        _ visible: Bool,
        matching query: MTLayerQuery,
        completionHandler: ((Result<[String], MTError>) -> Void)? = nil
    ) {
        deliver(completionHandler) { try await self.setVisibility(visible, matching: query) }
    }

    /// Shows or hides every layer of the given category in the current style.
    /// - Parameters:
    ///   - visible: Desired visibility.
    ///   - category: Category to update.
    ///   - completionHandler: A handler block receiving the identifiers of the affected layers.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setVisibility(
        _ visible: Bool,
        for category: MTLayerCategory,
        completionHandler: ((Result<[String], MTError>) -> Void)? = nil
    ) {
        deliver(completionHandler) { try await self.setVisibility(visible, for: category) }
    }

    /// Toggles the layers matching `query`: hides them all if any is visible, otherwise shows them all.
    /// - Parameters:
    ///   - query: Layers to toggle.
    ///   - completionHandler: A handler block receiving the new visibility, or `nil` if no layer matched.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func toggleVisibility(
        matching query: MTLayerQuery,
        completionHandler: ((Result<Bool?, MTError>) -> Void)? = nil
    ) {
        deliver(completionHandler) { try await self.toggleVisibility(matching: query) }
    }

    /// Toggles every layer of the given category.
    /// - Parameters:
    ///   - category: Category to toggle.
    ///   - completionHandler: A handler block receiving the new visibility, or `nil` if no layer matched.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func toggleVisibility(
        for category: MTLayerCategory,
        completionHandler: ((Result<Bool?, MTError>) -> Void)? = nil
    ) {
        deliver(completionHandler) { try await self.toggleVisibility(for: category) }
    }

    /// Builds legend entries for the given categories, skipping categories with no layers in the current style.
    /// - Parameters:
    ///   - categories: Categories to include, in the order they should appear.
    ///   - completionHandler: A handler block receiving the legend entries.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getLegend(
        for categories: [MTLayerCategory] = MTLayerCategory.allCases,
        completionHandler: ((Result<[MTLegendItem], MTError>) -> Void)?
    ) {
        deliver(completionHandler) { try await self.getLegend(for: categories) }
    }

    /// Runs an async operation and reports its outcome to a completion handler.
    private func deliver<T>(
        _ completionHandler: ((Result<T, MTError>) -> Void)?,
        operation: @escaping () async throws -> T
    ) {
        Task {
            do {
                let value = try await operation()
                completionHandler?(.success(value))
            } catch {
                MTLogger.log("\(error)", type: .error)
                completionHandler?(.failure(error as? MTError ?? MTError.bridgeNotLoaded))
            }
        }
    }
}
