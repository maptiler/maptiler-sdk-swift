//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTHillshadeIlluminationAnchor.swift
//  MapTilerSDK
//

/// Direction of light source when map is rotated.
public enum MTHillshadeIlluminationAnchor: String {
    /// The hillshade illumination is relative to the north direction.
    case map

    /// The hillshade illumination is relative to the top of the viewport.
    case viewport
}
