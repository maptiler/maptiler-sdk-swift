//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLineTranslateAnchor.swift
//  MapTilerSDK
//

/// Controls the frame of reference for line translate.
public enum MTLineTranslateAnchor: String {
    /// The line is translated relative to the map.
    case map

    /// The line is translated relative to the viewport.
    case viewport
}
