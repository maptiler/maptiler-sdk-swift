//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ZoomTo.swift
//  MapTilerSDK
//

import Foundation

package struct ZoomTo: MTCommand {
    var zoom: Double
    var animationOptions: MTAnimationOptions?

    package func toJS() -> JSString {
        let options = ZoomToOptions(animationOptions: animationOptions)
        var optionsString: JSString = options.toJSON() ?? ""

        optionsString = optionsString.replaceEasing()

        return "\(MTBridge.mapObject).zoomTo(\(zoom), \(optionsString));"
    }
}

package struct ZoomToOptions: Encodable {
    var animationOptions: MTAnimationOptions?

    package init(animationOptions: MTAnimationOptions?) {
        self.animationOptions = animationOptions
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let duration = animationOptions?.duration {
            try container.encode(duration, forKey: .duration)
        }

        if let offset = animationOptions?.offset {
            try container.encode(offset, forKey: .offset)
        }

        if let shouldAnimate = animationOptions?.shouldAnimate {
            try container.encode(shouldAnimate, forKey: .animate)
        }

        if let easing = animationOptions?.easing {
            try container.encode(easing.toJS(), forKey: .easing)
        }
    }

    package enum CodingKeys: String, CodingKey {
        case duration
        case offset
        case animate
        case easing
    }
}
