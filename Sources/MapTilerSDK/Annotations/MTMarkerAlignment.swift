//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMarkerAlignment.swift
//  MapTilerSDK
//

/// Alignment for marker rotation relative to map or viewport.
public enum MTMarkerRotationAlignment: String, Sendable, Codable {
    /// Aligns the marker's rotation with the map, reacting to map bearing.
    case map
    /// Aligns the marker's rotation with the viewport, ignoring map bearing.
    case viewport
    /// Alias for `.viewport`.
    case auto
}

/// Alignment for marker pitch relative to map or viewport.
public enum MTMarkerPitchAlignment: String, Sendable, Codable {
    /// Aligns the marker with the plane of the map.
    case map
    /// Aligns the marker with the viewport plane.
    case viewport
    /// Automatically matches the marker's rotation alignment.
    case auto
}
