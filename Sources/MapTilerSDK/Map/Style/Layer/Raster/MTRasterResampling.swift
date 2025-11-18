//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTRasterResampling.swift
//  MapTilerSDK
//

/// Resampling/interpolation method to use for overscaling.
public enum MTRasterResampling: String, Codable, Sendable {
    /// (Bi)linear filtering for smooth but slightly blurry overscaling.
    case linear

    /// Nearest neighbor filtering for sharp but pixelated overscaling.
    case nearest
}
