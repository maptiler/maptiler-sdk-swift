//
//  MTAnimationOptions.swift
//  MapTilerSDK
//

/// Provides animation options for navigation functions.
public struct MTAnimationOptions: Sendable, Codable {
    /// The animation's duration, measured in milliseconds.
    public var duration: Double?

    /// Point of the target center relative to real map container center at the end of animation.
    public var offset: MTPoint?

    /// Boolean indicating whether animation will occur.
    public var shouldAnimate: Bool?

    /// Boolean indicating whether animation is essential.
    public var isEssential: Bool?

    /// Rate of the change of the animation.
    public var easing: MTEasing?

    /// Initializes the options.
    public init(
        duration: Double? = nil,
        offset: MTPoint? = nil,
        shouldAnimate: Bool? = nil,
        isEssential: Bool? = nil,
        easing: MTEasing? = nil
    ) {
        self.duration = duration
        self.offset = offset
        self.shouldAnimate = shouldAnimate
        self.isEssential = isEssential
        self.easing = easing
    }
}
