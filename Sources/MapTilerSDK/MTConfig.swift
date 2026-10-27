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
    public static let version = "2.2.0"

    private static let lock = NSLock()
    nonisolated(unsafe) private static var _applicationIdentifier: String?

    // Custom User-Agent string for the SDK
    internal static var customUserAgent: String {
        let baseUA = "MapTiler-Mobile-SDK-iOS/\(version)"
        lock.lock()
        let appId = _applicationIdentifier
        lock.unlock()

        if let appId, !appId.isEmpty {
            return "\(appId) \(baseUA)"
        }
        return baseUA
    }

    nonisolated(unsafe) private static let _sharedURLSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["User-Agent": customUserAgent]
        return URLSession(configuration: configuration)
    }()

    // A configured URLSession that includes the SDK's User-Agent
    internal static var sharedURLSession: URLSession { _sharedURLSession }

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

    /// The MapTiler session ID used for sessionized requests and telemetry.
    private var sessionId: String?

    /// Default MapTiler API host.
    public static let defaultAPIHost = "api.maptiler.com"

    /// EU-based MapTiler API host.
    public static let euAPIHost = "api.maptiler.eu"

    nonisolated(unsafe) private static var _useEuEndpoints: Bool = false

    /// Boolean indicating whether the EU-based `api.maptiler.eu` host is currently in use
    /// instead of the default `api.maptiler.com`.
    ///
    ///  - Note: Defaults to false.
    public nonisolated var useEuEndpoints: Bool {
        Self.lock.lock()
        defer { Self.lock.unlock() }
        return Self._useEuEndpoints
    }

    /// The host currently used for the MapTiler API requests (`api.maptiler.com` or `api.maptiler.eu`).
    public nonisolated var apiHost: String {
        return useEuEndpoints ? Self.euAPIHost : Self.defaultAPIHost
    }

    /// The base URL currently used for the MapTiler API requests
    /// (`https://api.maptiler.com/` or `https://api.maptiler.eu/`).
    public nonisolated var apiURL: String {
        return "https://\(apiHost)/"
    }

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

    /// Switch between the default `api.maptiler.com` host and the EU-based `api.maptiler.eu` host.
    ///
    /// Set to `false` to switch back to the default.
    /// Make sure to call before map init and before offline downloads are started.
    /// - Parameters:
    ///   - useEuEndpoints:  Boolean indicating whether the EU-based host should be used.
    ///   - map:  Map view to apply to.
    /// - Note: Disabled by default
    public func setUseEuEndpoints(_ useEuEndpoints: Bool, for map: MTMapView? = nil) {
        Self.lock.lock()
        Self._useEuEndpoints = useEuEndpoints
        Self.lock.unlock()

        if let map {
            Task {
                await map.setUseEuEndpoints(useEuEndpoints)
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

    /// Sets a custom application identifier to be prepended to the SDK's User-Agent string.
    /// This allows you to restrict your MapTiler API key to specific applications.
    ///
    /// Must be called before `MTMapView` is initialized and before offline downloads are started.
    /// - Parameter identifier: The application identifier (e.g., your bundle identifier).
    ///   Only alphanumeric characters, periods, hyphens, and underscores are allowed.
    ///   All other characters will be removed.
    public func setApplicationIdentifier(_ identifier: String) {
        // Strict sanitization: Only allow alphanumeric, period, hyphen, and underscore.
        // This prevents HTTP Header Injection (CRLF) and malformed User-Agent strings.
        let allowedCharset = CharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._"
        )
        let sanitized = String(identifier.unicodeScalars.filter { allowedCharset.contains($0) })

        Self.lock.lock()
        Self._applicationIdentifier = sanitized
        Self.lock.unlock()
    }

    // Sets the MapTiler session ID.
    internal func setMaptilerSessionId(_ sessionId: String) {
        guard !sessionId.isEmpty else { return }
        self.sessionId = sessionId
    }

    /// Returns the current MapTiler session ID.
    public func getMaptilerSessionId() -> String? {
        return sessionId
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
