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

    internal init() {}
}
