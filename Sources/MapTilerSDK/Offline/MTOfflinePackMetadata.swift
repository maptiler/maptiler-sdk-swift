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

    /// Optional custom data, typically used to store application-specific context (e.g. JSON data).
    public let context: Data?

    /// The region definition specifying the bounding box, zoom levels, and style.
    public let region: MTOfflineRegionDefinition

    /// Initializes a new offline pack metadata object.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the pack. Defaults to a new UUID.
    ///   - region: The region definition for the pack.
    ///   - state: The initial state of the pack. Defaults to `.pending`.
    ///   - size: The initial size of the pack in bytes. Defaults to 0.
    ///   - createdAt: The creation date of the pack. Defaults to the current date.
    ///   - context: Optional custom context data. Defaults to nil.
    public init(
        id: UUID = UUID(),
        region: MTOfflineRegionDefinition,
        state: MTOfflinePackState = .pending,
        size: Int64 = 0,
        createdAt: Date = Date(),
        context: Data? = nil
    ) {
        self.id = id
        self.region = region
        self.state = state
        self.size = size
        self.createdAt = createdAt
        self.context = context
    }
}
