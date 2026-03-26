//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTHelperResults.swift
//  MapTilerSDK
//

import Foundation

/// The result returned after adding a point layer.
public struct MTPointLayerResult: Codable, Sendable {
    public let pointLayerId: String
    public let clusterLayerId: String?
    public let labelLayerId: String?
    public let pointSourceId: String
}

/// The result returned after adding a polygon layer.
public struct MTPolygonLayerResult: Codable, Sendable {
    public let polygonLayerId: String
    public let polygonOutlineLayerId: String?
    public let polygonSourceId: String
}

/// The result returned after adding a polyline layer.
public struct MTPolylineLayerResult: Codable, Sendable {
    public let polylineLayerId: String
    public let polylineOutlineLayerId: String?
    public let polylineSourceId: String
}

/// The result returned after adding a heatmap layer.
public struct MTHeatmapLayerResult: Codable, Sendable {
    public let heatmapLayerId: String
    public let heatmapSourceId: String
}
