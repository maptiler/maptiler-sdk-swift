//
//  MTStyle.swift
//  MapTilerSDK
//

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

    private var mapView: MTMapView!
    private var sources: [String: MTWeakSource] = [:]
    private var layers: [String: MTWeakLayer] = [:]

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

    /// Updates the map's style object with a new value.
    ///   - Parameters:
    ///     - referenceStyle:  Desired reference map style.
    ///     - styleVariant: Optional variant of the reference style.
    public func setStyle(_ referenceStyle: MTMapReferenceStyle, styleVariant: MTMapStyleVariant?) async {
        self.referenceStyle = referenceStyle
        self.styleVariant = styleVariant

        await mapView.runCommand(SetStyle(referenceStyle: referenceStyle, styleVariant: styleVariant))
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
    public func getIdForCurrentReferenceStyle() async -> String {
        return await mapView.getId(for: referenceStyle)
    }

    /// Returns ID for the provided reference style.
    /// - Parameters:
    ///     - referenceStyle:  Reference style for which to get id.
    public func getId(for referenceStyle: MTMapReferenceStyle) async -> String {
        return await mapView.getId(for: referenceStyle)
    }

    /// Returns ID of the current style variant, if it exists.
    public func getIdForCurrentStyleVariant() async -> String? {
        guard let styleVariant else {
            return nil
        }

        return await mapView.getId(for: styleVariant)
    }

    /// Returns id for the provided style variant.
    /// - Parameters:
    ///     - styleVariant:  Style variant for which to get id.
    public func getId(for styleVariant: MTMapStyleVariant) async -> String {
        return await mapView.getId(for: styleVariant)
    }

    /// Returns name of the current reference style.
    public func getNameForCurrentReferenceStyle() async -> String {
        return await mapView.getName(for: referenceStyle)
    }

    /// Returns name of the provided reference style.
    /// - Parameters:
    ///     - referenceStyle:  Reference style for which to get name.
    public func getName(for referenceStyle: MTMapReferenceStyle) async -> String {
        return await mapView.getName(for: referenceStyle)
    }

    /// Returns name of the current style variant, if it exists.
    public func getNameForCurrentStyleVariant() async -> String? {
        guard let styleVariant else {
            return nil
        }

        return await mapView.getName(for: styleVariant)
    }

    /// Returns name for the provided style variant.
    /// - Parameters:
    ///     - styleVariant:  Style variant for which to get name.
    public func getName(for styleVariant: MTMapStyleVariant) async -> String {
        return await mapView.getName(for: styleVariant)
    }
}

extension MTStyle {
    /// Adds a source to the map.
    ///
    /// - Parameters:
    ///     - source: Source to be added.
    /// - Throws: A ``MTStyleError.sourceAlreadyExists`` if source with the same
    /// id is already added to the map.
    public func addSource(_ source: MTSource) async throws {
        guard sources[source.identifier] == nil else {
            throw MTStyleError.sourceAlreadyExists
        }

        sources[source.identifier] = MTWeakSource(source: source)

        return await mapView.addSource(source)
    }

    /// Removes a source from the map.
    ///
    /// - Parameters:
    ///     - source: Source to be removed.
    /// - Throws: A ``MTStyleError.sourceNotFound`` if source does not exist on the map.
    public func removeSource(_ source: MTSource) async throws {
        guard sources[source.identifier] != nil else {
            throw MTStyleError.sourceNotFound
        }

        sources.removeValue(forKey: source.identifier)

        return await mapView.removeSource(source)
    }

    /// Returns a boolean indicating whether a source is already added to the map.
    public func sourceExists(_ source: MTSource) -> Bool {
        return sources[source.identifier] != nil
    }
}

extension MTStyle {
    /// Adds a layer to the map.
    ///
    /// - Parameters:
    ///     - layer: Layer to be added.
    /// - Throws: A ``MTStyleError.layerAlreadyExists`` if layer with the same
    /// id is already added to the map.
    public func addLayer(_ layer: MTLayer) async throws {
        guard layers[layer.identifier] == nil else {
            throw MTStyleError.layerAlreadyExists
        }

        layers[layer.identifier] = MTWeakLayer(layer: layer)

        return await mapView.addLayer(layer)
    }

    /// Removes a layer from the map.
    ///
    /// - Parameters:
    ///     - layer: Layer to be removed.
    /// - Throws: A ``MTStyleError.layerNotFound`` if layer does not exist on the map.
    public func removeLayer(_ layer: MTLayer) async throws {
        guard layers[layer.identifier] != nil else {
            throw MTStyleError.layerNotFound
        }

        layers.removeValue(forKey: layer.identifier)

        return await mapView.removeLayer(layer)
    }

    /// Returns a boolean indicating whether a layer is already added to the map.
    public func layerExists(_ layer: MTLayer) -> Bool {
        return layers[layer.identifier] != nil
    }
}

/// Represents the exceptions raised by the MTStyle object.
public enum MTStyleError: Error {
    /// Source with the same id already added to the map.
    case sourceAlreadyExists

    /// Source does not exist in the map.
    case sourceNotFound

    /// Layer with the same id already added to the map.
    case layerAlreadyExists

    /// Layer does not exist in the map.
    case layerNotFound
}
