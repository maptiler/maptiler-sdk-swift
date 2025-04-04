//
//  MTEasing.swift
//  MapTilerSDK
//

/// Representing the control of the change rate of the animation.
public enum MTEasing: String, Sendable, Codable {
    /// Follows the bezier curve.
    case bezierCurve

    /// Stars fast with a long, slow wind-down.
    case quint

    /// Starts slow and gradually increases speed.
    case cubic

    package func toJS() -> String {
        switch self {
        case .bezierCurve:
            return "function(t) { return t * t * (3 - 2 * t); }"
        case .quint:
            return "function(t) { return 1 - Math.pow(1 - t, 5); }"
        case .cubic:
            return "function(t) { return t * t * t; }"
        }
    }
}
