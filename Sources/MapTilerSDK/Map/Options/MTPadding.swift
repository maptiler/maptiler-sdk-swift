//
//  MTPadding.swift
//  MapTilerSDK
//

/// Options for setting padding on calls to map methods.
public struct MTPaddingOptions: Sendable, Codable {
    /// Left padding.
    var left: Double?

    /// Top padding.
    var top: Double?

    /// Right padding.
    var right: Double?

    /// Bottom padding.
    var bottom: Double?

    /// Initializes the padding options.
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
