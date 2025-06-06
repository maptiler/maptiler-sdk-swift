//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTStyle.swift
//  MapTilerSDK
//

import Foundation

struct StyleTask {
    let name: String
    let execute: () -> Void
}

/// The proxy object for the current map style.
///
/// Set of convenience methods for style, sources and layers manipulation.
/// MTStyle is nil until map loading is complete.
/// Since it is loaded asynchronously it should be manipulated only after ``MTEvent.didLoad`` triggers.
@MainActor
public class MTStyle {
    /// Current reference style of the map object.
    public private(set) var referenceStyle: MTMapReferenceStyle = .streets

    /// Current style variant of the map object.
    public private(set) var styleVariant: MTMapStyleVariant?

    private unowned var mapView: MTMapView!
    private var mapSources: [String: MTWeakSource] = [:]
    private var mapLayers: [String: MTWeakLayer] = [:]

    var queue: [StyleTask] = []

    package init(
        for mapView: MTMapView,
        with referenceStyle: MTMapReferenceStyle,
        and styleVariant: MTMapStyleVariant?
    ) {
        self.mapView = mapView

        Task {
            await setStyle(referenceStyle, styleVariant: styleVariant)
        }
    }

    package func processLayersQueueIfNeeded() {
        queue.forEach { $0.execute() }
        queue.removeAll()
    }

    /// Updates the map's style object with a new value.
    ///
    /// Setting the style resets custom sources and layers, so make sure to wait for style to load
    /// (``MTEvent/styleDidUpdate``) before adding them.
    ///   - Parameters:
    ///     - referenceStyle:  Desired reference map style.
    ///     - styleVariant: Optional variant of the reference style.
    ///     - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setStyle(
        _ referenceStyle: MTMapReferenceStyle,
        styleVariant: MTMapStyleVariant?,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        self.referenceStyle = referenceStyle
        self.styleVariant = styleVariant

        mapView.runCommand(
            SetStyle(
                referenceStyle: referenceStyle,
                styleVariant: styleVariant
            ),
            completion: completionHandler
        )
    }

    /// Returns variants for the current reference style if they exist.
    public func getVariantsForCurrentReferenceStyle() -> [MTMapStyleVariant]? {
        return referenceStyle.getVariants()
    }

    /// Returns variants for the provided reference style if they exist.
    /// - Parameters:
    ///     - referenceStyle:  Reference style for which to get variants.
    public func getVariants(for referenceStyle: MTMapReferenceStyle) -> [MTMapStyleVariant]? {
        return referenceStyle.getVariants()
    }

    /// Returns ID of the current reference style.
    ///   - Parameters:
    ///     - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getIdForCurrentReferenceStyle(completionHandler: ((Result<String, MTError>) -> Void)? = nil) {
        mapView.getId(for: referenceStyle, completionHandler: completionHandler)
    }

    /// Returns ID for the provided reference style.
    /// - Parameters:
    ///     - referenceStyle:  Reference style for which to get id.
    ///     - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getId(
        for referenceStyle: MTMapReferenceStyle,
        completionHandler: ((Result<String, MTError>) -> Void)? = nil
    ) {
        mapView.getId(for: referenceStyle, completionHandler: completionHandler)
    }

    /// Returns ID of the current style variant, if it exists.
    ///   - Parameters:
    ///     - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getIdForCurrentStyleVariant(completionHandler: ((Result<String, MTError>) -> Void)? = nil) {
        guard let styleVariant else {
            completionHandler?(.failure(MTError.bridgeNotLoaded))
            return
        }

        mapView.getId(for: styleVariant, completionHandler: completionHandler)
    }

    /// Returns id for the provided style variant.
    /// - Parameters:
    ///     - styleVariant:  Style variant for which to get id.
    ///     - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getId(
        for styleVariant: MTMapStyleVariant,
        completionHandler: ((Result<String, MTError>) -> Void)? = nil
    ) {
        mapView.getId(for: styleVariant, completionHandler: completionHandler)
    }

    /// Returns name of the current reference style.
    ///   - Parameters:
    ///     - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getNameForCurrentReferenceStyle(completionHandler: ((Result<String, MTError>) -> Void)? = nil) {
        mapView.getName(for: referenceStyle, completionHandler: completionHandler)
    }

    /// Returns name of the provided reference style.
    /// - Parameters:
    ///     - referenceStyle:  Reference style for which to get name.
    ///     - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getName(
        for referenceStyle: MTMapReferenceStyle,
        completionHandler: ((Result<String, MTError>) -> Void)? = nil
    ) {
        mapView.getName(for: referenceStyle, completionHandler: completionHandler)
    }

    /// Returns name of the current style variant, if it exists.
    ///   - Parameters:
    ///     - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getNameForCurrentStyleVariant(completionHandler: ((Result<String, MTError>) -> Void)? = nil) {
        guard let styleVariant else {
            completionHandler?(.failure(MTError.bridgeNotLoaded))
            return
        }

        mapView.getName(for: styleVariant, completionHandler: completionHandler)
    }

    /// Returns name for the provided style variant.
    /// - Parameters:
    ///     - styleVariant:  Style variant for which to get name.
    ///     - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getName(
        for styleVariant: MTMapStyleVariant,
        completionHandler: ((Result<String, MTError>) -> Void)? = nil
    ) {
        mapView.getName(for: styleVariant, completionHandler: completionHandler)
    }
}

extension MTStyle {
    /// Adds a source to the map.
    ///
    /// - Parameters:
    ///     - source: Source to be added.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addSource(_ source: MTSource, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        mapSources[source.identifier] = MTWeakSource(source: source)

        mapView.addSource(source, completionHandler: completionHandler)
    }

    /// Removes a source from the map.
    ///
    /// - Parameters:
    ///     - source: Source to be removed.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func removeSource(_ source: MTSource, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        mapSources.removeValue(forKey: source.identifier)

        mapView.removeSource(source, completionHandler: completionHandler)
    }

    /// Returns a boolean indicating whether a source is already added to the map.
    public func sourceExists(_ source: MTSource) -> Bool {
        return mapSources[source.identifier] != nil
    }
}

extension MTStyle {
    /// Adds a layer to the map.
    ///
    /// - Parameters:
    ///     - layer: Layer to be added.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addLayer(_ layer: MTLayer, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        mapLayers[layer.identifier] = MTWeakLayer(layer: layer)

        if mapSources[layer.sourceIdentifier] != nil {
            mapView.isSourceLoaded(id: layer.sourceIdentifier) { [weak self] result in
                guard let self else {
                    completionHandler?(.failure(MTError.bridgeNotLoaded))
                    return
                }

                switch result {
                case .success(let isLoaded):
                    if isLoaded {
                        mapView.addLayer(layer, completionHandler: completionHandler)
                    } else {
                        let layerTask = StyleTask(name: layer.identifier) { [weak self] in
                            self?.mapView.addLayer(layer, completionHandler: completionHandler)
                        }

                        queue.append(layerTask)
                    }
                case .failure(let error):
                    mapLayers[layer.identifier] = nil
                    completionHandler?(.failure(error))
                }
            }
        } else {
            completionHandler?(.failure(MTError.missingParent))
        }
    }

    /// Adds multiple layers to the map.
    ///
    /// - Parameters:
    ///     - layers: Layers to be added.
    /// - Note: All parent sources must be loaded prior to calling this method.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func addLayers(_ layers: [MTLayer], completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        for layer in layers {
            mapLayers[layer.identifier] = MTWeakLayer(layer: layer)
        }

        mapView.addLayers(layers, completionHandler: completionHandler)
    }

    /// Removes a layer from the map.
    ///
    /// - Parameters:
    ///     - layer: Layer to be removed.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func removeLayer(_ layer: MTLayer, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        mapLayers.removeValue(forKey: layer.identifier)

        mapView.removeLayer(layer, completionHandler: completionHandler)
    }

    /// Remove multiple layers from the map.
    ///
    /// - Parameters:
    ///     - layers: Layers to be removed.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func removeLayers(_ layers: [MTLayer], completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        for layer in layers {
            mapLayers.removeValue(forKey: layer.identifier)
        }

        mapView.removeLayers(layers, completionHandler: completionHandler)
    }

    /// Returns a boolean indicating whether a layer is already added to the map.
    public func layerExists(_ layer: MTLayer) -> Bool {
        return mapLayers[layer.identifier] != nil
    }
}

// Concurrency
extension MTStyle {
    /// Updates the map's style object with a new value.
    ///
    /// Setting the style resets custom sources and layers, so make sure to wait for style to load
    /// (``MTEvent/styleDidUpdate``) before adding them.
    ///   - Parameters:
    ///     - referenceStyle:  Desired reference map style.
    ///     - styleVariant: Optional variant of the reference style.
    public func setStyle(_ referenceStyle: MTMapReferenceStyle, styleVariant: MTMapStyleVariant?) async {
        await withCheckedContinuation { continuation in
            setStyle(referenceStyle, styleVariant: styleVariant) { _ in
                continuation.resume()
            }
        }
    }

    /// Returns ID of the current reference style.
    public func getIdForCurrentReferenceStyle() async -> String {
        await withCheckedContinuation { continuation in
            getIdForCurrentReferenceStyle { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: "")
                }
            }
        }
    }

    /// Returns ID for the provided reference style.
    /// - Parameters:
    ///     - referenceStyle:  Reference style for which to get id.
    public func getId(for referenceStyle: MTMapReferenceStyle) async -> String {
        await withCheckedContinuation { continuation in
            getId(for: referenceStyle) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: "")
                }
            }
        }
    }

    /// Returns ID of the current style variant, if it exists.
    public func getIdForCurrentStyleVariant() async -> String? {
        await withCheckedContinuation { continuation in
            getIdForCurrentStyleVariant { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: "")
                }
            }
        }
    }

    /// Returns id for the provided style variant.
    /// - Parameters:
    ///     - styleVariant:  Style variant for which to get id.
    public func getId(for styleVariant: MTMapStyleVariant) async -> String {
        await withCheckedContinuation { continuation in
            getId(for: styleVariant) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: "")
                }
            }
        }
    }

    /// Returns name of the current reference style.
    public func getNameForCurrentReferenceStyle() async -> String {
        await withCheckedContinuation { continuation in
            getNameForCurrentReferenceStyle { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: "")
                }
            }
        }
    }

    /// Returns name of the provided reference style.
    /// - Parameters:
    ///     - referenceStyle:  Reference style for which to get name.
    public func getName(for referenceStyle: MTMapReferenceStyle) async -> String {
        await withCheckedContinuation { continuation in
            getName(for: referenceStyle) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: "")
                }
            }
        }
    }

    /// Returns name of the current style variant, if it exists.
    public func getNameForCurrentStyleVariant() async -> String? {
        await withCheckedContinuation { continuation in
            getNameForCurrentStyleVariant { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: "")
                }
            }
        }
    }

    /// Returns name for the provided style variant.
    /// - Parameters:
    ///     - styleVariant:  Style variant for which to get name.
    public func getName(for styleVariant: MTMapStyleVariant) async -> String {
        await withCheckedContinuation { continuation in
            getName(for: styleVariant) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: "")
                }
            }
        }
    }

    /// Adds a source to the map.
    ///
    /// - Parameters:
    ///     - source: Source to be added.
    /// - Throws: A ``MTStyleError.sourceAlreadyExists`` if source with the same
    /// id is already added to the map.
    public func addSource(_ source: MTSource) async throws {
        guard mapSources[source.identifier] == nil else {
            throw MTStyleError.sourceAlreadyExists
        }

        try await withCheckedThrowingContinuation { continuation in
            addSource(source) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Removes a source from the map.
    ///
    /// - Parameters:
    ///     - source: Source to be removed.
    /// - Throws: A ``MTStyleError.sourceNotFound`` if source does not exist on the map.
    public func removeSource(_ source: MTSource) async throws {
        guard mapSources[source.identifier] != nil else {
            throw MTStyleError.sourceNotFound
        }

        try await withCheckedThrowingContinuation { continuation in
            removeSource(source) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Adds a layer to the map.
    ///
    /// - Parameters:
    ///     - layer: Layer to be added.
    /// - Throws: A ``MTStyleError.layerAlreadyExists`` if layer with the same
    /// id is already added to the map.
    public func addLayer(_ layer: MTLayer) async throws {
        guard mapLayers[layer.identifier] == nil else {
            throw MTStyleError.layerAlreadyExists
        }

        try await withCheckedThrowingContinuation { continuation in
            addLayer(layer) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Adds multiple layers to the map.
    ///
    /// - Parameters:
    ///     - layers: Layers to be added.
    /// - Note: All parent sources must be loaded prior to calling this method.
    public func addLayers(_ layers: [MTLayer]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            addLayers(layers) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Removes a layer from the map.
    ///
    /// - Parameters:
    ///     - layer: Layer to be removed.
    /// - Throws: A ``MTStyleError.layerNotFound`` if layer does not exist on the map.
    public func removeLayer(_ layer: MTLayer) async throws {
        guard mapLayers[layer.identifier] != nil else {
            throw MTStyleError.layerNotFound
        }

        try await withCheckedThrowingContinuation { continuation in
            removeLayer(layer) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Removes multiple layers from the map.
    ///
    /// - Parameters:
    ///     - layers: Layers to be removed.
    public func removeLayers(_ layers: [MTLayer]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            removeLayers(layers) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
