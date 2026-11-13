//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapView+CooperativeGestures.swift
//  MapTilerSDK
//

extension MTMapView {
    /// Enables cooperative gestures (panning requires two fingers).
    /// - Parameter completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func enableCooperativeGestures(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        options?.setCooperativeGestures(true)
        runCommand(CooperativeGesturesEnable(), completion: completionHandler)
    }

    /// Disables cooperative gestures.
    /// - Parameter completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func disableCooperativeGestures(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        options?.setCooperativeGestures(false)
        runCommand(CooperativeGesturesDisable(), completion: completionHandler)
    }

    /// Checks if cooperative gestures are enabled.
    /// - Parameter completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func isCooperativeGesturesEnabled(completionHandler: @escaping (Result<Bool, MTError>) -> Void) {
        runCommandWithBoolReturnValue(CooperativeGesturesIsEnabled(), completion: completionHandler)
    }
}

// Concurrency
extension MTMapView {
    /// Enables cooperative gestures (panning requires two fingers).
    public func enableCooperativeGestures() async {
        await withCheckedContinuation { continuation in
            enableCooperativeGestures { _ in
                continuation.resume()
            }
        }
    }

    /// Disables cooperative gestures.
    public func disableCooperativeGestures() async {
        await withCheckedContinuation { continuation in
            disableCooperativeGestures { _ in
                continuation.resume()
            }
        }
    }

    /// Checks if cooperative gestures are enabled.
    public func isCooperativeGesturesEnabled() async -> Bool {
        await withCheckedContinuation { continuation in
            isCooperativeGesturesEnabled { result in
                switch result {
                case .success(let isEnabled):
                    continuation.resume(returning: isEnabled)
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        }
    }
}
