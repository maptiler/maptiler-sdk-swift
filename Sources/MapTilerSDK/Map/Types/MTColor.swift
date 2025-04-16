//
//  MTColor.swift
//  MapTilerSDK
//

import UIKit

/// Color wrapper.
public struct MTColor: Codable {
    let hex: String

    /// CGColor representaion of the MTColor
    public var cgColor: CGColor? {
        return UIColor(hex: hex)?.cgColor
    }

    /// Initializes the MTColor with CGColor
    public init(color: CGColor) {
        self.hex = UIColor(cgColor: color).toHex()
    }
}
