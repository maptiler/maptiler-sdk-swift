//
//  MTLayer.swift
//  MapTilerSDK
//

/// Protocol requirements for all types of Layers.
public protocol MTLayer: Sendable, MTMapViewContent, AnyObject {
    var identifier: String { get set }
    var type: MTLayerType { get }
    var sourceIdentifier: String { get set }
    var maxZoom: Double? { get set }
    var minZoom: Double? { get set }
    var sourceLayer: String? { get set }
}
