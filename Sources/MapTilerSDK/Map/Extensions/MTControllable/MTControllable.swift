//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTControllable.swift
//  MapTilerSDK
//

import Foundation

/// Defines methods for adding the map controls.
@MainActor
public protocol MTControllable {
    /// Adds the MapTiler logo control to the map.
    ///  - Parameters:
    ///     - position: Map position to add the control to.
    func addMapTilerLogoControl(position: MTMapCorner) async

    /// Adds the logo control to the map.
    ///  - Parameters:
    ///     - logoURL: URL of the logo image resource.
    ///     - linkURL: URL of the anchor link.
    ///     - position: Map position to add the control to.
    func addLogoControl(name: String, logoURL: URL, linkURL: URL, position: MTMapCorner) async
}
