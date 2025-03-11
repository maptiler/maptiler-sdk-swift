//
//  MTFlyToOptions.swift
//  MapTilerSDK
//

import Foundation

/// Options describing the destination and animation of the flyTo transition.
public struct MTFlyToOptions: @unchecked Sendable, Codable {
    public var curve: Double?
    public var minZoom: Double?
    public var speed: Double?
    public var screenSpeed: Double?
    public var maxDuration: Double?

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
