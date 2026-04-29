//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import XCTest
@testable import MapTilerSDK

final class MTOfflineErrorTests: XCTestCase {

    func testInvalidURLErrorDescription() {
        let error = MTOfflineError.invalidURL("https://invalid-url.com")
        XCTAssertEqual(error.errorDescription, "The provided URL is invalid: https://invalid-url.com.")
        
        if case .invalidURL(let url) = error {
            XCTAssertEqual(url, "https://invalid-url.com")
        } else {
            XCTFail("Expected .invalidURL error")
        }
    }

    func testBadResponseErrorDescription() {
        let error = MTOfflineError.badResponse(statusCode: 404)
        XCTAssertEqual(error.errorDescription, "The server returned a bad response with status code: 404.")
        
        if case .badResponse(let code) = error {
            XCTAssertEqual(code, 404)
        } else {
            XCTFail("Expected .badResponse error")
        }
    }

    func testNetworkErrorDescription() {
        let urlError = URLError(.notConnectedToInternet)
        let error = MTOfflineError.networkError(urlError)
        XCTAssertEqual(error.errorDescription, "A network error occurred: \(urlError.localizedDescription).")
        
        if case .networkError(let wrappedError) = error {
            XCTAssertEqual(wrappedError, urlError)
        } else {
            XCTFail("Expected .networkError")
        }
    }

    func testMalformedJSONErrorDescription() {
        let error = MTOfflineError.malformedJSON
        XCTAssertEqual(error.errorDescription, "The JSON data is malformed or invalid.")
    }

    func testMissingKeyErrorDescription() {
        let error = MTOfflineError.missingKey("tiles")
        XCTAssertEqual(error.errorDescription, "A required key is missing in the JSON data: 'tiles'.")
        
        if case .missingKey(let key) = error {
            XCTAssertEqual(key, "tiles")
        } else {
            XCTFail("Expected .missingKey error")
        }
    }

    func testDecodingErrorDescription() {
        let context = DecodingError.Context(codingPath: [], debugDescription: "Type mismatch")
        let decodingError = DecodingError.typeMismatch(String.self, context)
        let error = MTOfflineError.decodingError(decodingError)
        
        XCTAssertEqual(error.errorDescription, "An error occurred while decoding JSON: \(decodingError.localizedDescription).")
        
        if case .decodingError(let wrappedError) = error {
            XCTAssertEqual(wrappedError.localizedDescription, decodingError.localizedDescription)
        } else {
            XCTFail("Expected .decodingError")
        }
    }

    func testInvalidBoundingBoxErrorDescription() {
        let error = MTOfflineError.invalidBoundingBox
        XCTAssertEqual(error.errorDescription, "The provided bounding box is invalid.")
    }

    func testReversedZoomLevelsErrorDescription() {
        let error = MTOfflineError.reversedZoomLevels(minZoom: 10.0, maxZoom: 5.0)
        XCTAssertEqual(error.errorDescription, "The minimum zoom level (10.0) is greater than the maximum zoom level (5.0).")
        
        if case .reversedZoomLevels(let minZ, let maxZ) = error {
            XCTAssertEqual(minZ, 10.0)
            XCTAssertEqual(maxZ, 5.0)
        } else {
            XCTFail("Expected .reversedZoomLevels error")
        }
    }

    func testMissingAPIKeyErrorDescription() {
        let error = MTOfflineError.missingAPIKey
        XCTAssertEqual(error.errorDescription, "The MapTiler API key is missing. Please configure the SDK with a valid API key.")
    }

    func testInsufficientStorageErrorDescription() {
        let error = MTOfflineError.insufficientStorage
        XCTAssertEqual(error.errorDescription, "There is not enough storage space available on the device to complete the download.")
    }

    func testExceedsMaximumTileCountErrorDescription() {
        let error = MTOfflineError.exceedsMaximumTileCount(limit: 10000, requested: 15000)
        XCTAssertEqual(error.errorDescription, "The download request of 15000 tiles exceeds the maximum allowed limit of 10000 tiles.")
        if case .exceedsMaximumTileCount(let limit, let requested) = error {
            XCTAssertEqual(limit, 10000)
            XCTAssertEqual(requested, 15000)
        } else {
            XCTFail("Expected .exceedsMaximumTileCount error")
        }
    }

    func testFileSystemErrorDescription() {
        let nsError = NSError(domain: NSCocoaErrorDomain, code: NSFileWriteOutOfSpaceError, userInfo: [NSLocalizedDescriptionKey: "Disk full"])
        let error = MTOfflineError.fileSystemError(nsError)
        XCTAssertEqual(error.errorDescription, "A file system error occurred: Disk full.")
        
        if case .fileSystemError(let wrappedError) = error {
            XCTAssertEqual((wrappedError as NSError).code, NSFileWriteOutOfSpaceError)
        } else {
            XCTFail("Expected .fileSystemError")
        }
    }

    func testCancelledErrorDescription() {
        let error = MTOfflineError.cancelled
        XCTAssertEqual(error.errorDescription, "The offline operation was cancelled.")
    }
    
    func testRecoverySuggestions() {
        XCTAssertEqual(
            MTOfflineError.invalidURL("").recoverySuggestion,
            "Ensure that the URL is properly formatted and all required parameters are URL-encoded."
        )
        
        XCTAssertEqual(
            MTOfflineError.badResponse(statusCode: 401).recoverySuggestion,
            "Verify that your API key is valid and has permission to access this resource."
        )
        
        XCTAssertEqual(
            MTOfflineError.badResponse(statusCode: 403).recoverySuggestion,
            "Verify that your API key is valid and has permission to access this resource."
        )
        
        XCTAssertEqual(
            MTOfflineError.badResponse(statusCode: 500).recoverySuggestion,
            "Try again later. If the problem persists, check the server status."
        )
        
        XCTAssertEqual(
            MTOfflineError.networkError(URLError(.notConnectedToInternet)).recoverySuggestion,
            "Check your internet connection and try again."
        )
        
        XCTAssertEqual(
            MTOfflineError.missingAPIKey.recoverySuggestion,
            "Ensure you set up the API key before starting a download."
        )
        
        XCTAssertEqual(
            MTOfflineError.insufficientStorage.recoverySuggestion,
            "Free up some space on your device before attempting to download this offline region."
        )
        
        XCTAssertEqual(
            MTOfflineError.exceedsMaximumTileCount(limit: 100, requested: 200).recoverySuggestion,
            "Try downloading a smaller geographic area or a more restricted range of zoom levels."
        )
        
        XCTAssertEqual(
            MTOfflineError.invalidBoundingBox.recoverySuggestion,
            "Ensure that min/max longitudes are between -180 and 180, and min/max latitudes are between -90 and 90."
        )
        
        XCTAssertEqual(
            MTOfflineError.reversedZoomLevels(minZoom: 10, maxZoom: 5).recoverySuggestion,
            "Ensure that the minimum zoom level is less than or equal to the maximum zoom level."
        )
        
        // Cases without recovery suggestions
        XCTAssertNil(MTOfflineError.malformedJSON.recoverySuggestion)
        XCTAssertNil(MTOfflineError.missingKey("").recoverySuggestion)
        XCTAssertNil(MTOfflineError.cancelled.recoverySuggestion)
    }
}
