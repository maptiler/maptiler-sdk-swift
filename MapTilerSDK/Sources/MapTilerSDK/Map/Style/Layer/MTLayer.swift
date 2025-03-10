//
//  MTLayer.swift
//  MapTilerSDK
//

/// Protocol requirements for all types of Layers.
public protocol MTLayer: Sendable {
    var identifier: String { get set }
    var type: MTLayerType { get set }
    var source: MTSource { get set }
    var maxZoom: Double { get set }
    var minZoom: Double { get set }
}
