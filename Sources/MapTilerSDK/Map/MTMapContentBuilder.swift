//
//  MTMapContentBuilder.swift
//  MapTilerSDK
//

/// Map view content requirements.
public protocol MTMapViewContent {
    /// Adds the content to the map DSL style.
    func addToMap(_ mapView: MTMapView)
}

/// Map view content builder.
@resultBuilder
public struct MTMapContentBuilder {
    public static func buildBlock(_ components: MTMapViewContent...) -> [MTMapViewContent] {
        return components
    }

    public static func buildOptionals(_ components: [MTMapViewContent]?) -> [MTMapViewContent] {
        return components ?? []
    }

    public static func buildEither(first components: [MTMapViewContent]) -> [MTMapViewContent] {
        return components
    }

    public static func buildEither(second components: [MTMapViewContent]) -> [MTMapViewContent] {
        return components
    }

    public static func buildArray(_ components: [[MTMapViewContent]]) -> [any MTMapViewContent] {
        return components.flatMap { $0 }
    }
}
