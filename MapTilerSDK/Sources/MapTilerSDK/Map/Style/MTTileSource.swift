//
//  MTTileSource.swift
//  MapTilerSDK
//

import Foundation

/// Protocol requirements for all tile type sources.
public protocol MTTileSource: MTSource {
    var attribution: String? { get set }
    var bounds: [Double] { get set }
    var maxZoom: Double { get set }
    var minZoom: Double { get set }
    var tiles: [String]? { get set }

    func setTiles(_ tiles: [String])
    func setURL(_ url: String)
}
