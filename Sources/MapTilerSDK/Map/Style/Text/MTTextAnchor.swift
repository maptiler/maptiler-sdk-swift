//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTextAnchor.swift
//  MapTilerSDK
//

/// Symbol text anchor positions.
public enum MTTextAnchor: String, Sendable {
    case center
    case left
    case right
    case top
    case bottom
    case topLeft = "top-left"
    case topRight = "top-right"
    case bottomLeft = "bottom-left"
    case bottomRight = "bottom-right"
}
