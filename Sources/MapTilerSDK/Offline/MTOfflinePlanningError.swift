//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflinePlanningError.swift
//  MapTilerSDK
//

import Foundation

// Errors that can occur during the offline planning process.
internal enum MTOfflinePlanningError: LocalizedError {
    // The bounding box has invalid coordinates.
    case invalidBoundingBox
    // The provided zoom range is invalid (e.g., min > max, or out of bounds).
    case invalidZoomRange
    /// The style definition could not be resolved or downloaded.
    case styleResolutionFailed
    // A network error occurred while planning.
    case networkError(Error)
    // The region exceeds the allowed tile count or storage limits.
    case regionTooLarge

    internal var errorDescription: String? {
        switch self {
        case .invalidBoundingBox:
            return "The provided bounding box has invalid coordinates."
        case .invalidZoomRange:
            return "The provided zoom range is invalid. Ensure minZoom <= maxZoom and both are within 0...22."
        case .styleResolutionFailed:
            return "Failed to resolve the map style."
        case .networkError(let error):
            return "A network error occurred: \(error.localizedDescription)"
        case .regionTooLarge:
            return "The requested offline region is too large."
        }
    }
}
