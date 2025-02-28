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

    package init(for mapView: MTMapView, with referenceStyle: MTMapReferenceStyle, and styleVariant: MTMapStyleVariant?) {
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
