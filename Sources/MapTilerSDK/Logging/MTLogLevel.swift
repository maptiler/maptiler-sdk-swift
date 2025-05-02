//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLogLevel.swift
//  MapTilerSDK
//

/// SDK log level.
public enum MTLogLevel: Sendable, Equatable {
    /// No logs will be printed.
    case none

    /// Only information logs will be printed.
    case info

    /// All logs will be printed.
    case debug(verbose: Bool = false)

    public static func == (lhs: MTLogLevel, rhs: MTLogLevel) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.info, .info):
            return true
        case (.debug(let lhsVerbose), .debug(let rhsVerbose)):
            return lhsVerbose == rhsVerbose
        default:
            return false
        }
    }

    public static func != (lhs: MTLogLevel, rhs: MTLogLevel) -> Bool {
        return !(lhs == rhs)
    }
}
