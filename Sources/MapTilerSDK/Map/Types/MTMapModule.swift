//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapModule.swift
//  MapTilerSDK
//

import Foundation

/// Protocol for creating external modules that can interact with the map's lifecycle
@MainActor
public protocol MTMapModule: AnyObject {
    /// Unique identifier for the module
    var id: String { get }

    /// Called when the module is attached to the MTMapView
    func onAttach(to mapView: MTMapView)

    /// Called when the underlying MapTiler map is initialized and ready
    func onMapReady()

    /// Called when the module receives a message from the map context.
    ///
    /// - Parameters:
    ///   - event: The name of the event fired from the map context.
    ///   - data: Optional payload associated with the event.
    func onMessageReceived(_ event: String, with data: [String: Any]?)
}
