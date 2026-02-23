//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTEventLevel.swift
//  MapTilerSDK
//

import Foundation

/// Controls which map events are forwarded from the map object.
///
/// - essential: Low-frequency lifecycle events only (ready, load, moveend, etc.) plus taps.
/// - cameraOnly: Forwards only camera events (move, zoom) in addition to minimal lifecycle.
/// - all: Default. Forwards all events including high-frequency move/zoom/touch/render
///   (use with caution on low-end devices).
/// - off: Minimal wiring to keep internal lifecycle (ready/load) functioning; all other events are suppressed.
public enum MTEventLevel: String, Codable, Sendable {
    case essential = "ESSENTIAL"

    /// Forwards only camera motion events (move, zoom) plus minimal lifecycle (ready/load is implicit).
    /// Use this to support overlays that track camera without wiring all touch/render events.
    case cameraOnly = "CAMERA_ONLY"
    case all = "ALL"
    case off = "OFF"
}
