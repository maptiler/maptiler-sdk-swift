//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflinePlanningError.swift
//  MapTilerSDK
//

import Foundation

/// Errors that can occur during the offline pack download process.
public enum MTOfflinePackError: LocalizedError {
    /// The bounding box has invalid coordinates.
    case invalidBoundingBox
    /// The provided zoom range is invalid (e.g., min > max, or out of bounds).
    case invalidZoomRange
    /// The style definition could not be resolved or downloaded.
    case styleResolutionFailed
    /// A network error occurred while planning.
    case networkError(Error)
    /// The region exceeds the allowed tile count or storage limits.
    case regionTooLarge
    /// The functionality is not yet implemented.
    case notImplemented
    /// The API key is missing from the configuration.
    case missingAPIKey
    /// The request was unauthorized (check your API key).
    case unauthorized
    /// The requested resource (style, tile, etc.) was not found.
    case resourceNotFound
    /// The API rate limit has been exceeded.
    case rateLimitExceeded
    /// An unexpected server-side error occurred.
    case serverError(statusCode: Int)

    public var errorDescription: String? {
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
        case .notImplemented:
            return "The functionality is not yet implemented."
        case .missingAPIKey:
            return "API key is missing. Set it via MTConfig.shared.setAPIKey(\"your_key\")."
        case .unauthorized:
            return "Unauthorized request. Verify your MapTiler API key."
        case .resourceNotFound:
            return "The requested resource was not found on the server."
        case .rateLimitExceeded:
            return "MapTiler API rate limit exceeded."
        case .serverError(let statusCode):
            return "Server returned an unexpected status code: \(statusCode)."
        }
    }
}
