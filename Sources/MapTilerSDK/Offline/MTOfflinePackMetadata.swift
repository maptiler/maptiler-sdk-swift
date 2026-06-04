//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflinePackMetadata.swift
//  MapTilerSDK
//

import Foundation

/// Represents the current state of an offline pack download.
public enum MTOfflinePackState: String, Sendable, Codable, Equatable {
    /// The pack has been created but download has not started.
    case pending
    /// The pack is currently downloading.
    case downloading
    /// The pack download was paused.
    case paused
    /// The pack download was canceled.
    case canceled
    /// The pack download completed successfully.
    case completed
    /// The pack download failed.
    case failed
    /// The pack has expired and its tiles are no longer usable.
    case expired
}

/// Metadata information about an offline pack.
///
/// This model is used to persist pack information such as its identifier,
/// current state, total size, and creation date.
public struct MTOfflinePackMetadata: Codable, Equatable, Sendable {
    /// The unique identifier of the pack.
    public let id: UUID

    /// The current state of the pack.
    public var state: MTOfflinePackState

    /// The total size of the pack in bytes.
    public var size: Int64

    /// The date when the pack was created.
    public let createdAt: Date

    /// The date when the pack expires.
    public var expiresAt: Date

    /// Optional custom data, typically used to store application-specific context (e.g. JSON data).
    public let context: Data?

    /// The region definition specifying the bounding box, zoom levels, and style.
    public let region: MTOfflineRegionDefinition

    /// Total number of resources required for the pack.
    public var totalResources: Int

    /// Total number of tile resources required for the pack.
    public var totalTileResources: Int

    /// Number of resources that have been successfully downloaded.
    public var downloadedResources: Int

    /// Returns true if the pack has passed its expiration date.
    public var isExpired: Bool {
        return Date() > expiresAt
    }

    /// Initializes a new offline pack metadata object.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the pack. Defaults to a new UUID.
    ///   - region: The region definition for the pack.
    ///   - state: The initial state of the pack. Defaults to `.pending`.
    ///   - size: The initial size of the pack in bytes. Defaults to 0.
    ///   - createdAt: The creation date of the pack. Defaults to the current date.
    ///   - expiresAt: The expiration date of the pack. Defaults to 30 days from now.
    ///   - context: Optional custom context data. Defaults to nil.
    ///   - totalResources: Total resources for the pack. Defaults to 0.
    ///   - downloadedResources: Downloaded resources for the pack. Defaults to 0.
    ///   - totalTileResources: Total tile resources for the pack. Defaults to 0.
    public init(
        id: UUID = UUID(),
        region: MTOfflineRegionDefinition,
        state: MTOfflinePackState = .pending,
        size: Int64 = 0,
        createdAt: Date = Date(),
        expiresAt: Date? = nil,
        context: Data? = nil,
        totalResources: Int = 0,
        downloadedResources: Int = 0,
        totalTileResources: Int = 0
    ) {
        self.id = id
        self.region = region
        self.state = state
        self.size = size
        self.createdAt = createdAt
        let defaultInterval = MTOfflineConfiguration.shared.defaultExpirationInterval
        self.expiresAt = expiresAt ?? createdAt.addingTimeInterval(defaultInterval)
        self.context = context
        self.totalResources = totalResources
        self.downloadedResources = downloadedResources
        self.totalTileResources = totalTileResources
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.state = try container.decode(MTOfflinePackState.self, forKey: .state)
        self.size = try container.decode(Int64.self, forKey: .size)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.context = try container.decodeIfPresent(Data.self, forKey: .context)
        self.region = try container.decode(MTOfflineRegionDefinition.self, forKey: .region)
        self.totalResources = (try? container.decode(Int.self, forKey: .totalResources)) ?? 0
        self.downloadedResources = (try? container.decode(Int.self, forKey: .downloadedResources)) ?? 0
        self.totalTileResources = (try? container.decode(Int.self, forKey: .totalTileResources)) ?? 0

        let defaultInterval = MTOfflineConfiguration.shared.defaultExpirationInterval
        let decodedExpiresAt = try container.decodeIfPresent(Date.self, forKey: .expiresAt)
        self.expiresAt = decodedExpiresAt ?? self.createdAt.addingTimeInterval(defaultInterval)
    }

    enum CodingKeys: String, CodingKey {
        case id, state, size, createdAt, expiresAt, context, region
        case totalResources, downloadedResources, totalTileResources
    }
}
