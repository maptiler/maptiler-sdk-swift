//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapResource.swift
//  MapTilerSDK
//

import Foundation

// Custom errors for Offline module HTTP operations
internal enum MTOfflineHTTPError: Error, Equatable {
    case invalidURL
    case timeout
    case offline
    case invalidResponse
    case notFound // HTTP 404
    case serverError(Int) // HTTP 5xx
    case clientError(Int) // HTTP 4xx other than 404
    case networkError(URLError)
    case unknown(String)

    static func == (lhs: MTOfflineHTTPError, rhs: MTOfflineHTTPError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
            (.timeout, .timeout),
            (.offline, .offline),
            (.invalidResponse, .invalidResponse),
            (.notFound, .notFound):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.clientError(let lhsCode), .clientError(let rhsCode)):
            return lhsCode == rhsCode
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.code == rhsError.code
        case (.unknown(let lhsMessage), .unknown(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
