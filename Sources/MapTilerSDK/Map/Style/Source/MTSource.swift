//
//  MTSource.swift
//  MapTilerSDK
//

import Foundation

/// Protocol requirements for all types of Sources.
public protocol MTSource: AnyObject, Sendable {
    var identifier: String { get set }
    var url: URL? { get set }
    var type: MTSourceType { get }
}
