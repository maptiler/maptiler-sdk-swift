//
//  MTGesture.swift
//  MapTilerSDK
//

/// Defines gestures behaviour.
@MainActor
public protocol MTGesture {
    var type: MTGestureType { get }
    func disable() async
    func enable() async
}
