//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ProjectionType.swift
//  MapTilerSDK
//

/// Type of projection the map uses.
public enum MTProjectionType: String, Sendable, Codable {
    /// Mercator projection.
    case mercator

    /// Globe projection.
    case globe
}
