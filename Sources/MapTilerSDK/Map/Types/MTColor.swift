//
//  MTColor.swift
//  MapTilerSDK
//

import UIKit

/// Color wrapper.
public struct MTColor: Codable {
    let hex: String

    public var cgColor: CGColor? {
        return UIColor(hex: hex)?.cgColor
    }

    public init(color: CGColor) {
        self.hex = UIColor(cgColor: color).toHex()
    }
}
