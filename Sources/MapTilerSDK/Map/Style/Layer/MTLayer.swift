//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLayer.swift
//  MapTilerSDK
//

/// Protocol requirements for all types of Layers.
public protocol MTLayer: Sendable, MTMapViewContent, AnyObject {
    /// Unique id of the layer.
    var identifier: String { get set }

    /// Type of the layer.
    var type: MTLayerType { get }

    /// Identifier of the source.
    var sourceIdentifier: String { get set }

    /// Max zoom of the layer.
    var maxZoom: Double? { get set }

    /// Min zoom of the layer.
    var minZoom: Double? { get set }

    /// Identifier of the source (main) layer to use.
    var sourceLayer: String? { get set }
}
