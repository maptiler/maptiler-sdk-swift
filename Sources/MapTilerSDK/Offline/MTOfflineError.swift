//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

/// Provides additional context for an offline error.
public struct MTOfflineContext: Sendable, Equatable {
    /// The URL of the resource that failed to download.
    public let url: URL

    /// An optional identifier for the resource (e.g., Tile ID, Source ID).
    public let resourceId: String?

    public init(url: URL, resourceId: String? = nil) {
        self.url = url
        self.resourceId = resourceId
    }
}

/// Represents errors that can occur during the offline planning and downloading process.
public enum MTOfflineError: Error, LocalizedError, Sendable, Equatable {
    // MARK: - HTTP Failures

    /// The provided URL was invalid.
    case invalidURL(String)

    /// The server returned a bad HTTP response with the given status code.
    case badResponse(statusCode: Int)

    /// A general network connectivity issue or URLSession error occurred.
    case networkError(URLError)

    /// The server returned a 204 No Content response, which is unexpected for this resource.
    case noContent

    /// The received content format or type does not match the expected format.
    case contentMismatch(expected: String, actual: String)

    // MARK: - JSON Failures

    /// The JSON data is malformed or invalid.
    case malformedJSON

    /// A required key is missing in style.json or TileJSON.
    case missingKey(String)

    /// An error occurred while decoding JSON into a Swift type.
    case decodingError(DecodingError)

    // MARK: - Domain-Specific Cases

    /// The provided bounding box is invalid.
    case invalidBoundingBox

    /// The minimum zoom level is greater than the maximum zoom level.
    case reversedZoomLevels(minZoom: Double, maxZoom: Double)

    /// The API key is missing.
    case missingAPIKey

    // MARK: - Storage and Limitations

    /// The device does not have enough available storage space to complete the download.
    case insufficientStorage

    /// The requested offline region exceeds the maximum allowed tile count or size.
    case exceedsMaximumTileCount(limit: Int, requested: Int)

    /// A file system error occurred while attempting to save or read offline data.
    case fileSystemError(String)

    /// The offline download or operation was cancelled by the user or system.
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let urlString):
            return "The provided URL is invalid: \(urlString)."
        case .badResponse(let statusCode):
            return "The server returned a bad response with status code: \(statusCode)."
        case .networkError(let error):
            return "A network error occurred: \(error.localizedDescription)."
        case .noContent:
            return "The server returned no content (204) for a required resource."
        case .contentMismatch(let expected, let actual):
            return "Content mismatch: expected \(expected), but received \(actual)."
        case .malformedJSON:
            return "The JSON data is malformed or invalid."
        case .missingKey(let key):
            return "A required key is missing in the JSON data: '\(key)'."
        case .decodingError(let error):
            return "An error occurred while decoding JSON: \(error.localizedDescription)."
        case .invalidBoundingBox:
            return "The provided bounding box is invalid."
        case .reversedZoomLevels(let minZoom, let maxZoom):
            return "The minimum zoom level (\(minZoom)) is greater than the maximum zoom level (\(maxZoom))."
        case .missingAPIKey:
            return "The MapTiler API key is missing. Please configure the SDK with a valid API key."
        case .insufficientStorage:
            return "There is not enough storage space available on the device to complete the download."
        case .exceedsMaximumTileCount(let limit, let requested):
            return "The download request of \(requested) tiles exceeds the maximum allowed limit of \(limit) tiles."
        case .fileSystemError(let message):
            return "A file system error occurred: \(message)."
        case .cancelled:
            return "The offline operation was cancelled."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Ensure that the URL is properly formatted and all required parameters are URL-encoded."
        case .badResponse(let statusCode):
            if statusCode == 401 || statusCode == 403 {
                return "Verify that your API key is valid and has permission to access this resource."
            }
            return "Try again later. If the problem persists, check the server status."
        case .networkError:
            return "Check your internet connection and try again."
        case .noContent:
            return "Check if the resource is available for the requested region and zoom level."
        case .contentMismatch:
            return "The server might be returning an error page instead of the requested resource. " +
                "Check your API key and parameters."
        case .missingAPIKey:
            return "Ensure you set up the API key before starting a download."
        case .insufficientStorage:
            return "Free up some space on your device before attempting to download this offline region."
        case .exceedsMaximumTileCount:
            return "Try downloading a smaller geographic area or a more restricted range of zoom levels."
        case .invalidBoundingBox:
            return "Ensure that min/max longitudes are between -180 and 180, and " +
                "min/max latitudes are between -90 and 90."
        case .reversedZoomLevels:
            return "Ensure that the minimum zoom level is less than or equal to the maximum zoom level."
        default:
            return nil
        }
    }

    public static func == (lhs: MTOfflineError, rhs: MTOfflineError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL(let l), .invalidURL(let r)): return l == r
        case (.badResponse(let l), .badResponse(let r)): return l == r
        case (.networkError(let l), .networkError(let r)): return l == r
        case (.noContent, .noContent): return true
        case (.contentMismatch(let le, let la), .contentMismatch(let re, let ra)): return le == re && la == ra
        case (.malformedJSON, .malformedJSON): return true
        case (.missingKey(let l), .missingKey(let r)): return l == r
        case (.decodingError, .decodingError): return true
        case (.invalidBoundingBox, .invalidBoundingBox): return true
        case (.reversedZoomLevels(let lmin, let lmax),
            .reversedZoomLevels(let rmin, let rmax)):
            return lmin == rmin && lmax == rmax
        case (.missingAPIKey, .missingAPIKey): return true
        case (.insufficientStorage, .insufficientStorage): return true
        case (.exceedsMaximumTileCount(let ll, let lr), .exceedsMaximumTileCount(let rl, let rr)):
            return ll == rl && lr == rr
        case (.fileSystemError(let l), .fileSystemError(let r)): return l == r
        case (.cancelled, .cancelled): return true
        default: return false
        }
    }
}
