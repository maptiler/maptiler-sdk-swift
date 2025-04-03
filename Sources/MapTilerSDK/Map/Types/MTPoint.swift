//
//  MTPoint.swift
//  MapTilerSDK
//

/// Two numbers representing x and y screen coordinates in pixels.
public struct MTPoint: Codable, Sendable {
    var x: Double
    var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
