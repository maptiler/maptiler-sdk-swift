//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ResetNorth.swift
//  MapTilerSDK
//

package struct ResetNorth: MTCommand {
    var animationOptions: MTAnimationOptions?

    package func toJS() -> JSString {
        let options = ResetNorthOptions(animationOptions: animationOptions)
        var optionsString: JSString = options.toJSON() ?? ""

        if optionsString.isEmpty || optionsString == "{}" {
            return "\(MTBridge.mapObject).resetNorth();"
        }

        optionsString = optionsString.replaceEasing()

        return "\(MTBridge.mapObject).resetNorth(\(optionsString));"
    }
}

package struct ResetNorthOptions: Encodable {
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
        case animate
        case isEssential = "essential"
        case easing
    }
}
