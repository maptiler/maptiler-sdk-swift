//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLog.swift
//  MapTilerSDK
//

/// Log object used with MTLogger.
public struct MTLog {
    /// Log message.
    public var message: String

    /// Type of the log.
    public var type: MTLogType

    /// Prints the log to the console.
    public func printLog() {
        print("\(type): \(message)")
    }
}
