//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTSourceData.swift
//  MapTilerSDK
//

/// The style spec representation of the source if the event has a dataType of source .
public struct MTSourceData: Codable {
    /// Type of the source.
    var type: String?

    /// Url of the source resource.
    var url: String?

    /// Attribution string.
    var attribution: String?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.type) {
            type = try container.decode(String.self, forKey: .type)
        }

        if container.contains(.url) {
            url = try container.decode(String.self, forKey: .url)
        }

        if container.contains(.attribution) {
            attribution = try container.decode(String.self, forKey: .attribution)
        }
    }

    package enum CodingKeys: String, CodingKey {
        case type
        case url
        case attribution
    }
}
