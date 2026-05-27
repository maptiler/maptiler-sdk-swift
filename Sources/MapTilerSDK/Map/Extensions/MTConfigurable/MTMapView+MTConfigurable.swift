//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapView+MTConfigurable.swift
//  MapTilerSDK
//

extension MTMapView: MTConfigurable {
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    package func setAPIKey(_ key: String, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetAPIKey(apiKey: key), completion: completionHandler)
    }

    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    package func setCaching(_ isEnabled: Bool, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetCaching(shouldCache: isEnabled), completion: completionHandler)
    }

    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    package func setSession(_ isEnabled: Bool, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetSession(shouldEnableSessionLogic: isEnabled), completion: completionHandler)
    }

    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    package func setUnit(_ unit: MTUnit, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetUnits(unit: unit), completion: completionHandler)
    }

    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    package func setTelemetry(_ isEnabled: Bool, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetTelemetry(shouldEnableTelemetry: isEnabled), completion: completionHandler)
    }

    /// Returns the current SDK session UUID used for sessionized requests and telemetry.
    /// - Parameter completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getMaptilerSessionId(completionHandler: @escaping (Result<String, MTError>) -> Void) {
        runCommandWithStringReturnValue(GetMaptilerSessionId(), completion: completionHandler)
    }

    /// Initializes resources that can be shared across maps to lower load
    /// times in some situations.
    ///
    /// By default, the lifecycle of these resources is managed automatically, and they are
    /// lazily initialized when a Map is first created. By invoking `prewarm()`, these
    /// resources will be created ahead of time, and will not be cleared when the last Map
    /// is removed from the page. This allows them to be re-used by new Map instances that
    /// are created later. They can be manually cleared by calling
    /// `clearPrewarmedResources()`.
    /// - Parameter completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func prewarm(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(Prewarm(), completion: completionHandler)
    }

    /// Clears up resources that have previously been created by `prewarm()`.
    ///
    /// Note that this is typically not necessary. You should only call this function
    /// if you expect the user of your app to not return to a Map view at any point
    /// in your application.
    /// - Parameter completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func clearPrewarmedResources(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(ClearPrewarmedResources(), completion: completionHandler)
    }
}

// Concurrency
extension MTMapView {
    package func setAPIKey(_ key: String) async {
        await withCheckedContinuation { continuation in
            setAPIKey(key) { _ in
                continuation.resume()
            }
        }
    }

    package func setCaching(_ isEnabled: Bool) async {
        await withCheckedContinuation { continuation in
            setCaching(isEnabled) { _ in
                continuation.resume()
            }
        }
    }

    package func setSession(_ isEnabled: Bool) async {
        await withCheckedContinuation { continuation in
            setSession(isEnabled) { _ in
                continuation.resume()
            }
        }
    }

    package func setUnit(_ unit: MTUnit) async {
        await withCheckedContinuation { continuation in
            setUnit(unit) { _ in
                continuation.resume()
            }
        }
    }

    package func setTelemetry(_ isEnabled: Bool) async {
        await withCheckedContinuation { continuation in
            setTelemetry(isEnabled) { _ in
                continuation.resume()
            }
        }
    }

    /// Returns the current SDK session UUID used for sessionized requests and telemetry.
    public func getMaptilerSessionId() async -> String {
        await withCheckedContinuation { continuation in
            getMaptilerSessionId { result in
                switch result {
                case .success(let sessionId):
                    continuation.resume(returning: sessionId)
                case .failure:
                    continuation.resume(returning: "")
                }
            }
        }
    }

    /// Initializes resources that can be shared across maps to lower load
    /// times in some situations.
    public func prewarm() async {
        await withCheckedContinuation { continuation in
            prewarm { _ in
                continuation.resume()
            }
        }
    }

    /// Clears up resources that have previously been created by `prewarm()`.
    public func clearPrewarmedResources() async {
        await withCheckedContinuation { continuation in
            clearPrewarmedResources { _ in
                continuation.resume()
            }
        }
    }
}
