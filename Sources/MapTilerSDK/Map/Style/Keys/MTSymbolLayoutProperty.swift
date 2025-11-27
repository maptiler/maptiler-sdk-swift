//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTSymbolLayoutProperty.swift
//  MapTilerSDK
//

/// Typed keys for symbol layout properties.
public enum MTSymbolLayoutProperty: String, Sendable {
    case textField = "text-field"
    case textSize = "text-size"
    case textAllowOverlap = "text-allow-overlap"
    case textAnchor = "text-anchor"
    case textFont = "text-font"
    case visibility
    case iconImage = "icon-image"
}
