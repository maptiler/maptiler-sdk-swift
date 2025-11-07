//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTFitBoundsOptions.swift
//  MapTilerSDK
//

/// Options that configure how the map fits to a set of bounds.
public struct MTFitBoundsOptions: Sendable, Codable {
    /// Padding to apply on each side of the viewport when fitting the bounds.
    public var padding: MTFitBoundsPadding?

    /// The maximum zoom level that the fit operation can produce.
    public var maxZoom: Double?

    /// Enables linear interpolation instead of the default easing.
    public var linear: Bool?

    /// Final bearing for the camera after the fit completes.
    public var bearing: Double?

    /// Final pitch for the camera after the fit completes.
    public var pitch: Double?

    /// Additional animation configuration.
    public var animationOptions: MTAnimationOptions?

    /// Creates a new set of fit bounds options.
    /// - Parameters:
    ///   - padding: Padding to apply around the fitted bounds.
    ///   - maxZoom: Upper zoom limit for the resulting camera.
    ///   - linear: Boolean indicating whether to animate linearly.
    ///   - bearing: Target bearing after the fit completes.
    ///   - pitch: Target pitch after the fit completes.
    ///   - animationOptions: Extra animation parameters.
    public init(
        padding: MTFitBoundsPadding? = nil,
        maxZoom: Double? = nil,
        linear: Bool? = nil,
        bearing: Double? = nil,
        pitch: Double? = nil,
        animationOptions: MTAnimationOptions? = nil
    ) {
        self.padding = padding
        self.maxZoom = maxZoom
        self.linear = linear
        self.bearing = bearing
        self.pitch = pitch
        self.animationOptions = animationOptions
    }

    package enum CodingKeys: String, CodingKey {
        case padding
        case maxZoom
        case linear
        case bearing
        case pitch
        case duration
        case offset
        case shouldAnimate
        case isEssential
        case easing
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.padding = try container.decodeIfPresent(MTFitBoundsPadding.self, forKey: .padding)
        self.maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)
        self.linear = try container.decodeIfPresent(Bool.self, forKey: .linear)
        self.bearing = try container.decodeIfPresent(Double.self, forKey: .bearing)
        self.pitch = try container.decodeIfPresent(Double.self, forKey: .pitch)

        let duration = try container.decodeIfPresent(Double.self, forKey: .duration)
        let offset = try container.decodeIfPresent(MTPoint.self, forKey: .offset)
        let shouldAnimate = try container.decodeIfPresent(Bool.self, forKey: .shouldAnimate)
        let isEssential = try container.decodeIfPresent(Bool.self, forKey: .isEssential)

        var easingValue: MTEasing?
        if let easing = try? container.decode(MTEasing.self, forKey: .easing) {
            easingValue = easing
        } else if let easingJS = try container.decodeIfPresent(String.self, forKey: .easing) {
            // Map JS function string back to the corresponding easing case, if possible.
            if easingJS == MTEasing.bezierCurve.toJS() {
                easingValue = .bezierCurve
            } else if easingJS == MTEasing.quint.toJS() {
                easingValue = .quint
            } else if easingJS == MTEasing.cubic.toJS() {
                easingValue = .cubic
            }
        }

        if duration != nil || offset != nil || shouldAnimate != nil || isEssential != nil || easingValue != nil {
            self.animationOptions = MTAnimationOptions(
                duration: duration,
                offset: offset,
                shouldAnimate: shouldAnimate,
                isEssential: isEssential,
                easing: easingValue
            )
        } else {
            self.animationOptions = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let padding {
            try container.encode(padding, forKey: .padding)
        }

        if let maxZoom {
            try container.encode(maxZoom, forKey: .maxZoom)
        }

        if let linear {
            try container.encode(linear, forKey: .linear)
        }

        if let bearing {
            try container.encode(bearing, forKey: .bearing)
        }

        if let pitch {
            try container.encode(pitch, forKey: .pitch)
        }

        if let duration = animationOptions?.duration {
            try container.encode(duration, forKey: .duration)
        }

        if let offset = animationOptions?.offset {
            try container.encode(offset, forKey: .offset)
        }

        if let shouldAnimate = animationOptions?.shouldAnimate {
            try container.encode(shouldAnimate, forKey: .shouldAnimate)
        }

        if let isEssential = animationOptions?.isEssential {
            try container.encode(isEssential, forKey: .isEssential)
        }

        if let easing = animationOptions?.easing {
            try container.encode(easing.toJS(), forKey: .easing)
        }
    }
}

/// Padding values accepted by ``MTFitBoundsOptions``.
public enum MTFitBoundsPadding: Sendable, Codable, Equatable {
    /// Applies the same padding to all sides.
    case uniform(Double)

    /// Applies directional padding values.
    case directional(MTPaddingOptions)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(Double.self) {
            self = .uniform(value)
        } else {
            let options = try container.decode(MTPaddingOptions.self)
            self = .directional(options)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .uniform(let value):
            try container.encode(value)
        case .directional(let options):
            try container.encode(options)
        }
    }
}
