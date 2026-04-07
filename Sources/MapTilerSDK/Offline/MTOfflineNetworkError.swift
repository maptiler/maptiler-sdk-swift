//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineNetworkError.swift
//  MapTilerSDK
//

import Foundation

/// Errors that can occur during offline network operations.
enum MTOfflineNetworkError: Error, Equatable {
    /// The request timed out.
    case timeout
    /// The server returned a bad response with the given status code.
    case badResponse(statusCode: Int)
    /// The provided URL was invalid.
    case invalidURL
    /// There is no active network connection.
    case noConnection
    /// An unknown error occurred.
    case unknown(String)
}
