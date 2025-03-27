//
//  MTLineJoin.swift
//  MapTilerSDK
//

/// The display of lines when joining.
public enum MTLineJoin: String {
    /// A join with a squared-off end which is drawn beyond the endpoint
    /// of the line at a distance of one-half of the line’s width.
    case bevel

    /// A join with a rounded end which is drawn beyond the endpoint of the line
    /// at a radius of one-half of the line’s width and centered on the endpoint of the line.
    case round

    /// A join with a sharp, angled corner which is drawn with the outer
    /// sides beyond the endpoint of the path until they meet.
    case miter
}
