//
//  MTMapContentBuilder.swift
//  MapTilerSDK
//

public protocol MTMapViewContent {
    func addToMap(_ mapView: MTMapView)
}

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
