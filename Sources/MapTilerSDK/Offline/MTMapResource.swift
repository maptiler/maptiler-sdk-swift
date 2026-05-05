//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapResource.swift
//  MapTilerSDK
//

import Foundation

// Represents a downloadable resource.
internal struct MTMapResource: Codable, Sendable {
    public let url: URL
    public let destinationPath: String
    public let size: Int64?

    public init(url: URL, destinationPath: String, size: Int64? = nil) {
        self.url = url
        self.destinationPath = destinationPath
        self.size = size
    }
}
