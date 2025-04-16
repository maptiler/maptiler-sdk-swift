//
//  MTGesture.swift
//  MapTilerSDK
//

/// Defines gestures behaviour.
@MainActor
public protocol MTGesture {
    /// Type of the gesture.
    var type: MTGestureType { get }

    /// Disables the gesture.
    func disable() async

    /// Enables the gesture.
    func enable() async
}
