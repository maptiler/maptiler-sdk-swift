//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTSpace.swift
//  MapTilerSDK
//

import Foundation

/// Predefined cubemap presets for space backgrounds.
public enum MTSpacePreset: String, Sendable, Codable, CaseIterable {
    /// Dark blue hsl(210, 100%, 4%) background and white stars (transparent background image).
    /// Space color changes the background color, stars always stay white.
    case space
    /// (default): Black background (image mask), space color changes the stars color, background always stays black.
    case stars
    /// Black half-transparent background with standard milkyway and stars.
    /// Space color changes the stars and milkyway color, background always stays black.
    case milkyway
    /// Black half-transparent background with subtle milkyway and less stars.
    /// Space color changes the stars and milkyway color, background always stays black.
    /// Black half-transparent background with standard milkyway and stars.
    /// Space color changes the stars and milkyway color, background always stays black.
    case milkywaySubtle = "milkyway-subtle"
    /// Black half-transparent background with bright milkyway and more stars.
    /// Space color changes the stars and milkyway color, background always stays black.
    case milkywayBright = "milkyway-bright"
    /// Full background image with natural space colors. Space color doesn’t change anything (non transparent image).
    case milkywayColored = "milkyway-colored"
}

/// Faces definition for a custom cubemap.
public struct MTSpaceFaces: Sendable, Codable {
    public var pX: URL
    public var nX: URL
    public var pY: URL
    public var nY: URL
    public var pZ: URL
    public var nZ: URL

    public init(pX: URL, nX: URL, pY: URL, nY: URL, pZ: URL, nZ: URL) {
        self.pX = pX
        self.nX = nX
        self.pY = pY
        self.nY = nY
        self.pZ = pZ
        self.nZ = nZ
    }
}

/// Path-based configuration for cubemap files.
///
/// This fetches all images from a path, this assumes all files are named px, nx, py, ny, pz, nz
/// and suffixed with the appropriate extension specified in format.
public struct MTSpacePath: Sendable, Codable {
    public var baseUrl: URL
    public var format: String?

    public init(baseUrl: URL, format: String? = nil) {
        self.baseUrl = baseUrl
        self.format = format
    }
}

/// Configuration for the "space" background.
public struct MTSpace: Sendable, Codable {
    /// Optional color to apply to the background and/or stars depending on preset.
    public var color: MTColor?

    /// Optional cubemap preset.
    public var preset: MTSpacePreset?

    /// Optional faces definition for a custom cubemap.
    public var faces: MTSpaceFaces?

    /// Optional path definition for a custom cubemap.
    public var path: MTSpacePath?

    public init(
        color: MTColor? = nil,
        preset: MTSpacePreset? = nil,
        faces: MTSpaceFaces? = nil,
        path: MTSpacePath? = nil
    ) {
        self.color = color
        self.preset = preset
        self.faces = faces
        self.path = path
    }

    enum CodingKeys: String, CodingKey {
        case color
        case preset
        case faces
        case path
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let colorString = try? container.decode(String.self, forKey: .color) {
            self.color = MTColor(hex: colorString)
        } else if let colorObject = try? container.decode(MTColor.self, forKey: .color) {
            self.color = colorObject
        } else {
            self.color = nil
        }

        self.preset = try? container.decode(MTSpacePreset.self, forKey: .preset)
        self.faces = try? container.decode(MTSpaceFaces.self, forKey: .faces)
        self.path = try? container.decode(MTSpacePath.self, forKey: .path)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let color {
            try container.encode(color.hex, forKey: .color)
        }
        if let preset {
            try container.encode(preset, forKey: .preset)
        }
        if let faces {
            try container.encode(faces, forKey: .faces)
        }
        if let path {
            try container.encode(path, forKey: .path)
        }
    }
}

/// Option that can enable default space or configure it.
public enum MTSpaceOption: Sendable, Codable {
    case enabled(Bool)
    case config(MTSpace)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let boolValue = try? container.decode(Bool.self) {
            self = .enabled(boolValue)
            return
        }

        let value = try container.decode(MTSpace.self)
        self = .config(value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .enabled(let flag):
            try container.encode(flag)
        case .config(let value):
            try container.encode(value)
        }
    }
}
