//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTStoragePath.swift
//  MapTilerSDK
//

import Foundation

// Represents a relative storage path within an offline pack directory.
internal struct MTStoragePath: Equatable, Hashable, CustomStringConvertible, Comparable {
    // The relative path string.
    internal let path: String

    internal init(path: String) {
        self.path = path
    }

    internal var description: String {
        return path
    }

    internal static func < (lhs: MTStoragePath, rhs: MTStoragePath) -> Bool {
        return lhs.path < rhs.path
    }
}
