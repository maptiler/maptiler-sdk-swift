//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapView+MTRendering.swift
//  MapTilerSDK
//

extension MTMapView: MTRendering {
    /// Returns the pixel ratio currently used by the map.
    /// - Parameter completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getPixelRatio(completionHandler: @escaping (Result<Double, MTError>) -> Void) {
        runCommandWithDoubleReturnValue(GetPixelRatio(), completion: completionHandler)
    }

    /// Sets the pixel ratio used by the map.
    /// - Parameters:
    ///   - pixelRatio: Pixel ratio value to apply.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setPixelRatio(
        _ pixelRatio: Double,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetPixelRatio(pixelRatio: pixelRatio), completion: completionHandler)

        options?.setPixelRatio(pixelRatio)
    }
}

// Concurrency
extension MTMapView {
    /// Returns the pixel ratio currently used by the map.
    public func getPixelRatio() async -> Double {
        await withCheckedContinuation { continuation in
            getPixelRatio { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: .nan)
                }
            }
        }
    }

    /// Sets the pixel ratio used by the map.
    /// - Parameter pixelRatio: Pixel ratio value to apply.
    public func setPixelRatio(_ pixelRatio: Double) async {
        await withCheckedContinuation { continuation in
            setPixelRatio(pixelRatio) { _ in
                continuation.resume()
            }
        }
    }
}
