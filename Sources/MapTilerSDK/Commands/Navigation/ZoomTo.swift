//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ZoomTo.swift
//  MapTilerSDK
//

package struct ZoomTo: MTCommand {
    var zoom: Double
    var animationOptions: MTAnimationOptions?

    package func toJS() -> JSString {
        let options = ZoomToOptions(zoom: zoom, animationOptions: animationOptions)
        var optionsString: JSString = options.toJSON() ?? ""

        optionsString = optionsString.replaceEasing()

        return "\(MTBridge.mapObject).zoomTo(\(zoom), \(optionsString));"
    }
}

package struct ZoomToOptions: Codable {
    var zoom: Double
    var animationOptions: MTAnimationOptions?

    package init(zoom: Double, animationOptions: MTAnimationOptions?) {
        self.zoom = zoom
        self.animationOptions = animationOptions
    }

    package init(from decoder: any Decoder) throws {
        // Not used, but required by Codable
        self.zoom = 0
        self.animationOptions = try MTAnimationOptions(from: decoder)
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // zoomTo(zoom, options) - zoom is passed as first argument, options as second.
        // options contains animation options.

        if let duration = animationOptions?.duration {
            try container.encode(duration, forKey: .duration)
        }

        if let offset = animationOptions?.offset {
            try container.encode(offset, forKey: .offset)
        }

        if let shouldAnimate = animationOptions?.shouldAnimate {
            try container.encode(shouldAnimate, forKey: .shouldAnimate)
        }

        if let isEssential = animationOptions?.isEssential {
            try container.encode(isEssential, forKey: .isEssential)
        }

        if let easing = animationOptions?.easing {
            try container.encode(easing.toJS(), forKey: .easing)
        }
    }

    package enum CodingKeys: String, CodingKey {
        case duration
        case offset
        case shouldAnimate
        case isEssential
        case easing
    }
}
