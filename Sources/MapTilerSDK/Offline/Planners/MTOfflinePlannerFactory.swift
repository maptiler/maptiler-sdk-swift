//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflinePlannerFactory.swift
//  MapTilerSDK
//

import Foundation

internal class MTOfflinePlannerFactory {
    static func createPlanner(configuration: MTOfflineConfiguration = .shared) -> MTOfflinePlanner {
        switch configuration.plannerType {
        case .local:
            return MTLocalPlanner()
        case .server:
            return MTServerPlanner()
        }
    }
}
