//
//  MTZoomable.swift
//  MapTilerSDK
//

/// Defines methods for manipulating zoom level.
@MainActor
public protocol MTZoomable {
    func zoomIn() async
    func zoomOut() async
}
