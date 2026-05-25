//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineConfiguration.swift
//  MapTilerSDK
//

import Foundation

internal enum MTOfflinePlannerType {
    case local
    case server
}

internal class MTOfflineConfiguration: @unchecked Sendable {
    internal static let shared = MTOfflineConfiguration()

    private let lock = NSLock()
    private var _plannerType: MTOfflinePlannerType = .local
    private var _userMaxTileCount: Int = 15000

    /// Hard safety limit
    internal let internalMaxTileLimit: Int = 15000

    /// The default expiration interval for offline packs (30 days).
    internal let defaultExpirationInterval: TimeInterval = 30 * 24 * 60 * 60

    /// The default grace period before an expired pack is deleted (7 days).
    internal let defaultGracePeriod: TimeInterval = 7 * 24 * 60 * 60

    internal var plannerType: MTOfflinePlannerType {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _plannerType
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _plannerType = newValue
        }
    }

    /// The global limit set by the SDK consumer.
    internal var userMaxTileCount: Int {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _userMaxTileCount
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _userMaxTileCount = newValue
        }
    }

    /// The effective global limit (most restrictive of internal vs user).
    internal var effectiveGlobalLimit: Int {
        min(userMaxTileCount, internalMaxTileLimit)
    }

    internal init() {}
}
