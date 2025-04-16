//
//  MTSource.swift
//  MapTilerSDK
//

import Foundation

/// Protocol requirements for all types of Sources.
public protocol MTSource: AnyObject, MTMapViewContent, Sendable {
    /// Unique id of the source.
    var identifier: String { get set }

    /// URL pointing to the source resource.
    var url: URL? { get set }

    /// Type of the source.
    var type: MTSourceType { get }
}
