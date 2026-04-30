//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

/// Represents errors that can occur during the offline planning and downloading process.
public enum MTOfflineError: Error, LocalizedError {
    // MARK: - HTTP Failures

    /// The provided URL was invalid.
    case invalidURL(String)

    /// The server returned a bad HTTP response with the given status code.
    case badResponse(statusCode: Int)

    /// A general network connectivity issue or URLSession error occurred.
    case networkError(URLError)

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
    case fileSystemError(Error)

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
        case .fileSystemError(let error):
            return "A file system error occurred: \(error.localizedDescription)."
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
}
