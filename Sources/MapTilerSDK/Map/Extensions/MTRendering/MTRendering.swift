//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTRendering.swift
//  MapTilerSDK
//

/// Defines methods for adjusting rendering parameters.
@MainActor
public protocol MTRendering {
    /// Returns the pixel ratio currently used by the map.
    func getPixelRatio() async -> Double

    /// Sets the pixel ratio to use when rendering the map.
    /// - Parameter pixelRatio: Pixel ratio value to apply.
    func setPixelRatio(_ pixelRatio: Double) async
}
