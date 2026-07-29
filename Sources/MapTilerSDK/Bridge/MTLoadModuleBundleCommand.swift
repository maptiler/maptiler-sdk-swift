//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLoadModuleBundleCommand.swift
//  MapTilerSDK
//

import Foundation

/// A command used to load and evaluate a module's core bundle into the map's runtime engine.
public struct MTLoadModuleBundleCommand: MTCommand {
    /// The string representation of the bundle to load.
    public let bundleString: String

    /// Initializes a new command to load a module's bundle.
    ///
    /// - Parameter bundleString: The raw string content of the module's bundle.
    public init(bundleString: String) {
        self.bundleString = bundleString
    }

    public func toJS() -> JSString {
        return bundleString
    }
}
