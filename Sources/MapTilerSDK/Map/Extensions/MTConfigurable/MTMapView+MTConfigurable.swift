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
}
