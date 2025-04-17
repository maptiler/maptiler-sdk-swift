//
//  MTLogType.swift
//  MapTilerSDK
//

/// Type of log messages in the SDK.
public enum MTLogType: Sendable {
    /// Informational messages.
    case info

    /// Warning messages.
    case warning

    /// SDK Errors.
    case error

    /// Critical SDK errors.
    case criticalError

    /// Event messages.
    case event
}
