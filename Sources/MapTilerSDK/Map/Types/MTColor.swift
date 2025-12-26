//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTColor.swift
//  MapTilerSDK
//

import UIKit

/// Color wrapper.
public struct MTColor: Sendable, Codable, Equatable {
    let hex: String

    /// CGColor representation of the MTColor.
    public var cgColor: CGColor? {
        return UIColor(hex: hex)?.cgColor
    }

    /// Initializes the MTColor with CGColor
    public init(color: CGColor) {
        self.hex = UIColor(cgColor: color).toHex()
    }
}
