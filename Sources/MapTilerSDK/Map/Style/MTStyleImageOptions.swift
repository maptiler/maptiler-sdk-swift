//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTStyleImageOptions.swift
//  MapTilerSDK
//

import Foundation

/// Configuration that controls how an image is registered within the MapTiler style.
public struct MTStyleImageOptions: Codable, Equatable, Sendable {
    /// Pixel ratio of the supplied image. Values below zero are ignored.
    public var pixelRatio: Double?

    /// Indicates whether the image should be interpreted as a signed distance field.
    public var sdf: Bool?

    /// Horizontal stretch ranges applied when rendering the image.
    public var stretchX: [Stretch]?

    /// Vertical stretch ranges applied when rendering the image.
    public var stretchY: [Stretch]?

    /// Content insets that describe the stretchable area of the image.
    public var content: Content?

    /// Creates a new set of image options.
    /// - Parameters:
    ///   - pixelRatio: Pixel ratio of the supplied image.
    ///   - sdf: Indicates whether the image should be interpreted as a signed distance field.
    ///   - stretchX: Horizontal stretch ranges applied when rendering the image.
    ///   - stretchY: Vertical stretch ranges applied when rendering the image.
    ///   - content: Insets describing the stretchable area of the image.
    public init(
        pixelRatio: Double? = nil,
        sdf: Bool? = nil,
        stretchX: [Stretch]? = nil,
        stretchY: [Stretch]? = nil,
        content: Content? = nil
    ) {
        if let pixelRatio = pixelRatio, pixelRatio > 0 {
            self.pixelRatio = pixelRatio
        } else {
            self.pixelRatio = nil
        }

        self.sdf = sdf
        self.stretchX = stretchX?.isEmpty == true ? nil : stretchX
        self.stretchY = stretchY?.isEmpty == true ? nil : stretchY
        self.content = content
    }
}

public extension MTStyleImageOptions {
    /// Describes a stretchable segment on an axis.
    struct Stretch: Codable, Equatable, Sendable {
        /// Starting point of the stretch range.
        public var from: Double
        /// Ending point of the stretch range.
        public var to: Double

        /// Creates a new stretch segment.
        /// - Parameters:
        ///   - from: Starting point of the stretch range.
        ///   - to: Ending point of the stretch range.
        public init(from: Double, to: Double) {
            self.from = from
            self.to = to
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(from)
            try container.encode(to)
        }

        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            from = try container.decode(Double.self)
            to = try container.decode(Double.self)
        }
    }

    /// Insets that describe the stretchable area of the image.
    struct Content: Codable, Equatable, Sendable {
        /// Left inset.
        public var left: Double
        /// Top inset.
        public var top: Double
        /// Right inset.
        public var right: Double
        /// Bottom inset.
        public var bottom: Double

        /// Creates a new content inset definition.
        /// - Parameters:
        ///   - left: Left inset.
        ///   - top: Top inset.
        ///   - right: Right inset.
        ///   - bottom: Bottom inset.
        public init(left: Double, top: Double, right: Double, bottom: Double) {
            self.left = left
            self.top = top
            self.right = right
            self.bottom = bottom
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(left)
            try container.encode(top)
            try container.encode(right)
            try container.encode(bottom)
        }

        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            left = try container.decode(Double.self)
            top = try container.decode(Double.self)
            right = try container.decode(Double.self)
            bottom = try container.decode(Double.self)
        }
    }
}
