//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTCirclePaintProperty.swift
//  MapTilerSDK
//

/// Typed keys for circle paint properties.
public enum MTCirclePaintProperty: String, Sendable {
    case blur = "circle-blur"
    case color = "circle-color"
    case opacity = "circle-opacity"
    case radius = "circle-radius"
    case strokeColor = "circle-stroke-color"
    case strokeOpacity = "circle-stroke-opacity"
    case strokeWidth = "circle-stroke-width"
    case translate = "circle-translate"
    case translateAnchor = "circle-translate-anchor"
    case pitchAlignment = "circle-pitch-alignment"
    case pitchScale = "circle-pitch-scale"
}
