//
//  MTPoint.swift
//  MapTilerSDK
//

/// Two numbers representing x and y screen coordinates in pixels.
public struct MTPoint: Codable, Sendable {
    /// X value
    var x: Double

    /// Y value.
    var y: Double

    /// Initializes the point with x and y values.
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
