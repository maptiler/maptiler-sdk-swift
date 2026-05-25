//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTConfig.swift
//  MapTilerSDK
//

import Foundation

/// Object representing the SDK global settings.
///
/// Exposes properties and options such as API Key and caching preferences.
public actor MTConfig {
    public static let shared = MTConfig()
    private init() {}

    private var apiKey: String?
    private var unit: MTUnit = .metric

    /// SDK version
    public static let version = "1.3.2"

    // Custom User-Agent string for the SDK
    internal static let customUserAgent = "MapTiler-Mobile-SDK-iOS/\(version)"

    // A configured URLSession that includes the SDK's User-Agent
    internal static let sharedURLSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["User-Agent": customUserAgent]
        return URLSession(configuration: configuration)
    }()

    /// SDK log level.
    public private(set) var logLevel: MTLogLevel = .none

    /// Boolean indicating whether caching is enabled.
    ///
    ///  - Note: Defaults to true.
    public private(set) var isCachingEnabled: Bool = true

    /// Boolean indicating whether session logic is enabled.
    ///
    /// This allows MapTiler to enable "session based billing".
    ///  - Note: Defaults to true.
    ///  - SeeAlso: ``https://docs.maptiler.com/guides/maps-apis/maps-platform/what-is-map-session-in-maptiler-cloud/``
    public private(set) var isSessionLogicEnabled: Bool = true

    /// Boolean indicating whether telemetry is enabled.
    ///
    /// The telemetry is very valuable to the team at MapTiler because it shares information about
    /// where to add the extra effort. It also helps spotting some incompatibility issues that may
    /// arise between the SDK and a specific version of a module. It consist in sending the SDK version,
    /// API Key, MapTiler session ID, if tile caching is enabled, if language specified at initialization,
    /// if terrain is activated at initialization, if globe projection is activated at initialization.
    ///  - Note: Defaults to true.
    public private(set) var isTelemetryEnabled: Bool = true

    /// Sets the SDK log level.
    /// - Parameters:
    ///   - level:  The desired SDK log level.
    ///  - Note: Default: .none
    public func setLogLevel(_ level: MTLogLevel) {
        self.logLevel = level
    }

    /// Sets the MapTiler API key.
    /// - Parameters:
    ///   - apiKey:  The MapTiler API Key.
    ///   - map:  Map view to apply to.
    public func setAPIKey(_ apiKey: String, for map: MTMapView? = nil) {
        self.apiKey = apiKey

        if let map {
            Task {
                await  map.setAPIKey(apiKey)
            }
        }
    }

    /// Returns the MapTiler API key.
    public func getAPIKey() -> String? {
        guard let apiKey else {
            MTLogger.log("API key not set! Call setAPIKey on MTConfig first.", type: .warning)

            return nil
        }

        return apiKey
    }

    /// Sets the caching mechanism.
    /// - Parameters:
    ///   - isEnabled:  Boolean indicating whether caching is enabled.
    ///   - map:  Map view to apply to.
    /// - Note: Enabled by default
    public func setCaching(_ isEnabled: Bool, for map: MTMapView) {
        self.isCachingEnabled = isEnabled

        Task {
            await map.setCaching(isCachingEnabled)
        }
    }

    /// Sets the session logic.
    ///
    ///  Make sure to call before map init or use MTMapOptions to supply before map init.
    /// - Parameters:
    ///   - isEnabled:  Boolean indicating whether session logic is enabled.
    ///   - map:  Map view to apply to.
    /// - Note: Enabled by default
    /// - SeeAlso: ``https://docs.maptiler.com/guides/maps-apis/maps-platform/what-is-map-session-in-maptiler-cloud/``
    public func setSessionLogic(_ isEnabled: Bool, for map: MTMapView) {
        self.isSessionLogicEnabled = isEnabled

        Task {
            await map.setSession(isSessionLogicEnabled)
        }
    }

    /// Sets the unit of measurement.
    /// - Parameters:
    ///   - unit:  The MTUnit type.
    ///   - map:  Map view to apply to.
    /// - Note: Default: .metric
    public func setUnit(_ unit: MTUnit, for map: MTMapView) {
        self.unit = unit

        Task {
            await map.setUnit(unit)
        }
    }

    /// Returns the unit of measurement.
    public func getUnit() -> MTUnit? {
        return unit
    }

    /// Sets the maximum number of tiles allowed for a single offline region download.
    /// This prevents users from accidentally downloading massive areas that consume too much storage.
    /// Note: MapTiler enforces an internal safety limit (currently 15,000 tiles). If you provide a value
    /// higher than the internal limit, the internal limit will be enforced.
    /// - Parameter maxTileCount: The maximum allowed tiles (default is 15,000).
    public func setOfflineMaxTileCount(_ maxTileCount: Int) {
        MTOfflineConfiguration.shared.userMaxTileCount = maxTileCount
    }

    /// Sets the telemetry.
    /// - Parameters:
    ///   - isEnabled:  Boolean indicating whether telemetry is enabled.
    ///   - map:  Map view to apply to.
    /// - Note: Enabled by default
    public func setTelemetry(_ isEnabled: Bool, for map: MTMapView) {
        self.isTelemetryEnabled = isEnabled

        Task {
            await map.setTelemetry(isTelemetryEnabled)
        }
    }

    /// Handles events for the background URLSession.
    /// Call this from your AppDelegate's `application(_:handleEventsForBackgroundURLSession:completionHandler:)`
    /// - Parameters:
    ///   - identifier: The identifier of the URLSession.
    ///   - completionHandler: The completion handler provided by the app delegate.
    public static func handleEventsForBackgroundURLSession(
        identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        if identifier == "com.maptiler.sdk.offline.backgroundSession" {
            MTOfflineBackgroundManager.shared.setup(completionHandler: completionHandler)
        } else {
            // Not our session, call completion immediately
            completionHandler()
        }
    }
}
