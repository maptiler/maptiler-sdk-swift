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

    public var code: Int {
        switch self {
        case .exception(body: let body):
            return body.code
        case .invalidResultType(description: let description):
            return 90
        case .unsupportedReturnType(description: let description):
            return 91
        case .unknown(description: let description):
            return 92
        case .bridgeNotLoaded:
            return 93
        }
    }

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
        }
    }
}

/// Represents body of the MTError exception.
public struct MTException: Sendable {
    public var code: Int
    public var reason: String
}
