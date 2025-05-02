//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTError.swift
//  MapTilerSDK
//

/// Represents all the errors that can occur in the MapTiler SDK.
///
/// All methods within the SDK throw MTError.
public enum MTError: Error {
    /// Method execution failed with exception.
    ///
    ///  - Parameter body: Exception details.
    case exception(body: MTException)

    /// Method execution returned an invalid result.
    ///
    ///  - Parameter description: Debug description of the return type.
    case invalidResultType(description: String)

    /// Method execution returned unsupported type.
    ///
    ///  - Parameter description: Debug description of the command that returned unsupported type.
    case unsupportedReturnType(description: String)

    /// Method execution resulted in an unknown error.
    ///
    ///  - Parameter description: Debug description of error.
    case unknown(description: String)

    /// Method execution halted. Bridge and/or Map are not loaded.
    case bridgeNotLoaded

    /// Method execution failed due to missing parent entity.
    case missingParent

    /// Numerical code of the exception.
    public var code: Int {
        switch self {
        case .exception(body: let body):
            return body.code
        case .invalidResultType:
            return 90
        case .unsupportedReturnType:
            return 91
        case .unknown:
            return 92
        case .bridgeNotLoaded:
            return 93
        case .missingParent:
            return 95
        }
    }

    /// Explanation of the exception.
    public var reason: String {
        switch self {
        case .exception(body: let body):
            return body.reason
        case .invalidResultType(description: let description):
            return description
        case .unsupportedReturnType(description: let description):
            return description
        case .unknown(description: let description):
            return description
        case .bridgeNotLoaded:
            return "Bridge and/or Map are not loaded."
        case .missingParent:
            return "Missing parent entity."
        }
    }
}

/// Represents body of the MTError exception.
public struct MTException: Sendable {
    /// Exception code.
    public var code: Int
    /// Explanation of the exception.
    public var reason: String
}
