//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTFillExtrusionTranslateAnchor.swift
//  MapTilerSDK
//

/// Controls the frame of reference for fill-extrusion translate.
public enum MTFillExtrusionTranslateAnchor: String {
    /// The fill extrusion is translated relative to the map.
    case map

    /// The fill extrusion is translated relative to the viewport.
    case viewport
}
