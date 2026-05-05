//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflinePackProgress.swift
//  MapTilerSDK
//

/// Represents the download progress of an offline pack.
public struct MTOfflinePackProgress: Sendable, Equatable, Codable {
    /// Total number of resources required for the pack.
    public var totalResources: Int
    /// Number of resources that have been successfully downloaded.
    public var downloadedResources: Int
    /// The completion percentage (0.0 to 1.0).
    public var percentage: Double {
        guard totalResources > 0 else { return 0 }
        return Double(downloadedResources) / Double(totalResources)
    }
}
