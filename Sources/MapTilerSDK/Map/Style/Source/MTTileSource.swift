//
//  MTTileSource.swift
//  MapTilerSDK
//

import Foundation

/// Protocol requirements for all tile type sources.
public protocol MTTileSource: MTSource {
    /// Attribution string.
    var attribution: String? { get set }

    /// Bounds of the source.
    var bounds: [Double] { get set }

    /// Max zoom of the source.
    var maxZoom: Double { get set }

    /// Min zoom of the source.
    var minZoom: Double { get set }

    /// List of URLs pointing to the tiles resources.
    var tiles: [URL]? { get set }
}
