//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTileEstimate.swift
//  MapTilerSDK
//

import Foundation

/// An estimate for an offline tile download.
public struct MTTileEstimate {
    /// Statistics for the download.
    public let stats: MTPackStats

    public init(stats: MTPackStats) {
        self.stats = stats
    }
}
