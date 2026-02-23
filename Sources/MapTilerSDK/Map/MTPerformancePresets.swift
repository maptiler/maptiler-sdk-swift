//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPerformancePresets.swift
//  MapTilerSDK
//

import Foundation

/// Performance-oriented presets for MapTiler Swift SDK.
public enum MTPerformancePresets {
    /// Lean performance preset: prioritize responsiveness and bytes over fidelity.
    ///
    /// Applied overrides (favor performance over fidelity):
    /// - pixelRatio = 1.0
    /// - shouldRefreshExpiredTiles = false
    /// - cancelPendingTileRequestsWhileZooming = true
    /// - maxTileCacheZoomLevels = 4.0 (if unset)
    /// - crossSourceCollisionsAreEnabled = false
    /// - eventLevel = ESSENTIAL (keeps low-frequency events; per-frame events opt-in)
    /// - highFrequencyEventThrottleMs = 150 (when ALL is enabled)
    public static func leanPerformance(base: MTMapOptions = MTMapOptions()) -> MTMapOptions {
        var options = base
        options.setPixelRatio(1.0)
        options.setShouldRefreshExpiredTiles(false)
        options.setCancelPendingTileRequestsWhileZooming(true)
        if options.maxTileCacheZoomLevels == nil {
            options.setMaxTileCacheZoomLevels(4.0)
        }
        options.setCrossSourceCollisionsAreEnabled(false)
        options.setEventLevel(.essential)
        if options.highFrequencyEventThrottleMs == nil {
            options.setHighFrequencyEventThrottleMs(150)
        }
        return options
    }

    /// Returns a new [MTMapOptions] based on [base] with balanced performance defaults.
    ///
    /// Keeps crisper rendering by using a higher pixel ratio.
    ///
    /// Applied overrides:
    /// - pixelRatio = base.pixelRatio ?: 1.5 (sharper than 1.0)
    /// - shouldRefreshExpiredTiles = false
    /// - cancelPendingTileRequestsWhileZooming = true
    /// - maxTileCacheZoomLevels = 4.0 (if unset)
    /// - crossSourceCollisionsAreEnabled = false
    /// - eventLevel = ESSENTIAL (per-frame events opt-in)
    /// - highFrequencyEventThrottleMs = 150 (when ALL is enabled)
    public static func balancedPerformance(base: MTMapOptions = MTMapOptions()) -> MTMapOptions {
        var options = base
        if options.pixelRatio == nil {
            options.setPixelRatio(1.5)
        }
        options.setShouldRefreshExpiredTiles(false)
        options.setCancelPendingTileRequestsWhileZooming(true)
        if options.maxTileCacheZoomLevels == nil {
            options.setMaxTileCacheZoomLevels(4.0)
        }
        options.setCrossSourceCollisionsAreEnabled(false)
        options.setEventLevel(.essential)
        if options.highFrequencyEventThrottleMs == nil {
            options.setHighFrequencyEventThrottleMs(150)
        }
        return options
    }

    /// Returns a new [MTMapOptions] based on [base] tuned for higher-end devices.
    ///
    /// Focuses on visual fidelity while keeping sensible performance guardrails.
    ///
    /// Applied overrides:
    /// - pixelRatio = base.pixelRatio ?: 2.0 (very crisp; test for memory on low-end)
    /// - shouldRefreshExpiredTiles = true (prefer up-to-date tiles)
    /// - cancelPendingTileRequestsWhileZooming = false (allow progressive detail during zoom)
    /// - maxTileCacheZoomLevels = 6.0 (if unset) to reduce churn when navigating
    /// - crossSourceCollisionsAreEnabled = base.crossSourceCollisionsAreEnabled ?: true
    /// - eventLevel = ALL
    /// - highFrequencyEventThrottleMs = 100 (slightly more responsive when ALL is enabled)
    public static func highFidelity(base: MTMapOptions = MTMapOptions()) -> MTMapOptions {
        var options = base
        if options.pixelRatio == nil {
            options.setPixelRatio(2.0)
        }
        options.setShouldRefreshExpiredTiles(true)
        options.setCancelPendingTileRequestsWhileZooming(false)
        if options.maxTileCacheZoomLevels == nil {
            options.setMaxTileCacheZoomLevels(6.0)
        }
        // crossSourceCollisionsAreEnabled is already base value
        options.setEventLevel(.all)
        if options.highFrequencyEventThrottleMs == nil {
            options.setHighFrequencyEventThrottleMs(100)
        }
        return options
    }
}

public extension MTMapOptions {
    /// Applies the lean performance preset over this instance, returning a new options object.
    func withLeanPerformanceDefaults() -> MTMapOptions {
        return MTPerformancePresets.leanPerformance(base: self)
    }

    /// Returns a new [MTMapOptions] with balanced performance defaults applied over this instance.
    func withBalancedPerformanceDefaults() -> MTMapOptions {
        return MTPerformancePresets.balancedPerformance(base: self)
    }

    /// Returns a new [MTMapOptions] with high-fidelity defaults applied over this instance.
    func withHighFidelityDefaults() -> MTMapOptions {
        return MTPerformancePresets.highFidelity(base: self)
    }
}
