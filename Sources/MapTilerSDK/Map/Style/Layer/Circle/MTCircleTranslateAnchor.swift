//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTCircleTranslateAnchor.swift
//  MapTilerSDK
//

/// Controls the frame of reference for circle translate.
public enum MTCircleTranslateAnchor: String {
    /// The circle is translated relative to the map.
    case map

    /// The circle is translated relative to the viewport.
    case viewport
}
