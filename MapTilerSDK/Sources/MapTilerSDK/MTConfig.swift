//
//  MTConfig.swift
//  MapTilerSDK
//

/// Object representing the SDK global settings.
///
/// Exposes properties and options such as API Key and Language preferences.
public actor MTConfig {
    public static let shared = MTConfig()
    private init() {}

    private var apiKey: String?
    private var unit: MTUnit = .metric
    private var primaryLanguage: MTLanguage = .special(.auto)

    /// SDK log level.
    public private(set) var logLevel: MTLogLevel = .none

    /// Boolean indicating whether caching is enabled.
    public private(set) var isCachingEnabled: Bool = true

    /// Boolean indicating whether session logic is enabled.
    public private(set) var isSessionLogicEnabled: Bool = true

    /// Boolean indicating whether telemetry is enabled.
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
    public func setAPIKey(_ apiKey: String) {
        self.apiKey = apiKey
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
    /// - Note: Enabled by default
    public func setCaching(_ isEnabled: Bool) {
        self.isCachingEnabled = isEnabled
    }

    /// Sets the session logic.
    /// - Parameters:
    ///   - isEnabled:  Boolean indicating whether session logic is enabled.
    /// - Note: Enabled by default
    public func setSessionLogic(_ isEnabled: Bool) {
        self.isSessionLogicEnabled = isEnabled
    }

    /// Sets the unit of measurement.
    /// - Parameters:
    ///   - unit:  The MTUnit type.
    /// - Note: Default: .metric
    public func setUnit(_ unit: MTUnit) {
        self.unit = unit
    }

    /// Returns the unit of measurement.
    public func getUnit() -> MTUnit? {
        return unit
    }

    /// Sets the primary language of the map.
    /// - Parameters:
    ///   - language:  The Language to use.
    /// - Note: Default: .auto
    public func setPrimaryLanguage(_ language: MTLanguage) {
        self.primaryLanguage = language
    }

    /// Returns the primary language of the map.
    public func getPrimaryLanguage() -> MTLanguage? {
        return primaryLanguage
    }

    /// Sets the telemetry.
    /// - Parameters:
    ///   - isEnabled:  Boolean indicating whether telemetry is enabled.
    /// - Note: Enabled by default
    public func setTelemetry(_ isEnabled: Bool) {
        self.isTelemetryEnabled = isEnabled
    }
}
