//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTStyle+TypedHelpers.swift
//  MapTilerSDK
//

import UIKit

/// Typed convenience wrappers
public extension MTStyle {
    // MARK: Circle helpers

    /// Sets circle radius as a step expression on a feature key.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func setCircleRadiusStep(
        layerId: String,
        key: MTFeatureKey,
        default defaultRadius: Double,
        stops: [(Double, Double)],
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let expr = MTExpression.step(
            input: MTExpression.get(key),
            default: .number(defaultRadius),
            stops: stops.map { ($0.0, .number($0.1)) }
        )
        setPaintProperty(
            layerId: layerId,
            name: "circle-radius",
            value: expr,
            completionHandler: completionHandler
        )
    }

    /// Sets circle color as a step expression on a feature key.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func setCircleColorStep(
        layerId: String,
        key: MTFeatureKey,
        default defaultColor: UIColor,
        stops: [(Double, UIColor)],
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let expr = MTExpression.step(
            input: MTExpression.get(key),
            default: .color(defaultColor),
            stops: stops.map { ($0.0, .color($0.1)) }
        )
        setPaintProperty(
            layerId: layerId,
            name: "circle-color",
            value: expr,
            completionHandler: completionHandler
        )
    }

    // MARK: Symbol helpers

    /// Sets text field using a common token.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func setTextFieldToken(
        layerId: String,
        token: MTTextToken,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        setLayoutProperty(
            layerId: layerId,
            name: "text-field",
            value: .string(token.rawValue),
            completionHandler: completionHandler
        )
    }

    /// Sets text size.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func setTextSize(
        layerId: String,
        size: Double,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        setLayoutProperty(
            layerId: layerId,
            name: "text-size",
            value: .number(size),
            completionHandler: completionHandler
        )
    }

    /// Sets text allow overlap.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func setTextAllowOverlap(
        layerId: String,
        _ allow: Bool,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        setLayoutProperty(
            layerId: layerId,
            name: "text-allow-overlap",
            value: .bool(allow),
            completionHandler: completionHandler
        )
    }

    /// Sets text color.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func setTextColor(
        layerId: String,
        color: UIColor,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        setPaintProperty(
            layerId: layerId,
            name: "text-color",
            value: .color(color),
            completionHandler: completionHandler
        )
    }

    /// Sets text anchor.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func setTextAnchor(
        layerId: String,
        anchor: MTTextAnchor,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        setLayoutProperty(
            layerId: layerId,
            name: "text-anchor",
            value: .string(anchor.rawValue),
            completionHandler: completionHandler
        )
    }

    /// Sets text font. Provide an ordered list of font families.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func setTextFont(
        layerId: String,
        fonts: [String],
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        let value: MTPropertyValue = .array(fonts.map { .string($0) })
        setLayoutProperty(
            layerId: layerId,
            name: "text-font",
            value: value,
            completionHandler: completionHandler
        )
    }
}

// MARK: - Async versions
public extension MTStyle {
    /// Sets circle radius as a step expression on a feature key.
    func setCircleRadiusStep(
        layerId: String,
        key: MTFeatureKey,
        default defaultRadius: Double,
        stops: [(Double, Double)]
    ) async {
        await withCheckedContinuation { continuation in
            setCircleRadiusStep(layerId: layerId, key: key, default: defaultRadius, stops: stops) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets circle color as a step expression on a feature key.
    func setCircleColorStep(
        layerId: String,
        key: MTFeatureKey,
        default defaultColor: UIColor,
        stops: [(Double, UIColor)]
    ) async {
        await withCheckedContinuation { continuation in
            setCircleColorStep(layerId: layerId, key: key, default: defaultColor, stops: stops) { _ in
                continuation.resume()
            }
        }
    }

    // Sets text field using a common token.
    func setTextFieldToken(layerId: String, token: MTTextToken) async {
        await withCheckedContinuation { continuation in
            setTextFieldToken(layerId: layerId, token: token) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets text size.
    func setTextSize(layerId: String, size: Double) async {
        await withCheckedContinuation { continuation in
            setTextSize(layerId: layerId, size: size) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets text allow overlap.
    func setTextAllowOverlap(layerId: String, _ allow: Bool) async {
        await withCheckedContinuation { continuation in
            setTextAllowOverlap(layerId: layerId, allow) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets text color.
    func setTextColor(layerId: String, color: UIColor) async {
        await withCheckedContinuation { continuation in
            setTextColor(layerId: layerId, color: color) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets text anchor.
    func setTextAnchor(layerId: String, anchor: MTTextAnchor) async {
        await withCheckedContinuation { continuation in
            setTextAnchor(layerId: layerId, anchor: anchor) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets text font. Provide an ordered list of font families.
    func setTextFont(layerId: String, fonts: [String]) async {
        await withCheckedContinuation { continuation in
            setTextFont(layerId: layerId, fonts: fonts) { _ in
                continuation.resume()
            }
        }
    }
}
