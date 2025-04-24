//
//  MTFlyToOptions.swift
//  MapTilerSDK
//

import Foundation

/// Options describing the destination and animation of the flyTo transition.
public struct MTFlyToOptions: Sendable, Codable {
    /// The zooming "curve" that will occur along the flight path.
    public var curve: Double?

    /// The zero-based zoom level at the peak of the flight path.
    public var minZoom: Double?

    /// The average speed of the animation defined in relation to curve.
    public var speed: Double?

    /// The average speed of the animation measured in screenfuls per second, assuming a linear timing curve.
    public var screenSpeed: Double?

    /// The animation's maximum duration, measured in milliseconds.
    public var maxDuration: Double?

    /// Initializes the options.
    public init(
        curve: Double? = nil,
        minZoom: Double? = nil,
        speed: Double? = nil,
        screenSpeed: Double? = nil,
        maxDuration: Double? = nil
    ) {
        self.curve = curve
        self.minZoom = minZoom
        self.speed = speed
        self.screenSpeed = screenSpeed
        self.maxDuration = maxDuration
    }
}
