//
//  MTLineCap.swift
//  MapTilerSDK
//

/// The display of line endings.
public enum MTLineCap: String {
    /// A cap with a squared-off end which is drawn to the exact endpoint of the line.
    case butt

    /// A cap with a rounded end which is drawn beyond the endpoint of the line
    /// at a radius of one-half of the line’s width and centered on the endpoint of the line.
    case round

    /// A cap with a squared-off end which is drawn beyond the endpoint of the line
    /// at a distance of one-half of the line’s width.
    case square
}
