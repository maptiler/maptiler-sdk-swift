//
//  MTPadding.swift
//  MapTilerSDK
//

/// Options for setting padding on calls to map methods.
public struct MTPaddingOptions: @unchecked Sendable, Codable {
    var left: Double?
    var top: Double?
    var right: Double?
    var bottom: Double?

    public init(
        left: Double? = nil,
        top: Double? = nil,
        right: Double? = nil,
        bottom: Double? = nil
    ) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }
}
