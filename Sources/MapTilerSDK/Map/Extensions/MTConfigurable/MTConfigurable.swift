//
//  MTConfigurable.swift
//  MapTilerSDK
//

// Defines methods for sdk configurations.
@MainActor
package protocol MTConfigurable {
    func setAPIKey(_ key: String) async
    func setCaching(_ isEnabled: Bool) async
    func setSession(_ isEnabled: Bool) async
    func setUnit(_ unit: MTUnit) async
    func setTelemetry(_ isEnabled: Bool) async
}
