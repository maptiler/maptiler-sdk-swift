//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  FlyTo.swift
//  MapTilerSDK
//

import CoreLocation

package struct FlyTo: MTCommand {
    var center: CLLocationCoordinate2D
    var options: MTFlyToOptions?
    var animationOptions: MTAnimationOptions?

    package func toJS() -> JSString {
        let options = FlyToOptions(center: center, options: options, animationOptions: animationOptions)
        var optionsString: JSString = options.toJSON() ?? ""

        optionsString = optionsString.replaceEasing()

        return "\(MTBridge.mapObject).flyTo(\(optionsString));"
    }
}

package struct FlyToOptions: Codable {
    var center: CLLocationCoordinate2D
    var options: MTFlyToOptions?
    var animationOptions: MTAnimationOptions?

    package init(center: CLLocationCoordinate2D, options: MTFlyToOptions?, animationOptions: MTAnimationOptions?) {
        self.center = center
        self.options = options
        self.animationOptions = animationOptions
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.center = try container.decode(CLLocationCoordinate2D.self, forKey: .center)
        self.options = try MTFlyToOptions(from: decoder)
        self.animationOptions = try MTAnimationOptions(from: decoder)
    }

    // swiftlint:disable cyclomatic_complexity
    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(center, forKey: .center)

        if let curve = options?.curve {
            try container.encode(curve, forKey: .curve)
        }

        if let minZoom = options?.minZoom {
            try container.encode(minZoom, forKey: .minZoom)
        }

        if let speed = options?.speed {
            try container.encode(speed, forKey: .speed)
        }

        if let screenSpeed = options?.screenSpeed {
            try container.encode(screenSpeed, forKey: .screenSpeed)
        }

        if let maxDuration = options?.maxDuration {
            try container.encode(maxDuration, forKey: .maxDuration)
        }

        if let duration = animationOptions?.duration {
            try container.encode(duration, forKey: .duration)
        }

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
    // swiftlint:enable cyclomatic_complexity

    package enum CodingKeys: String, CodingKey {
        case center
        case curve
        case minZoom
        case speed
        case screenSpeed
        case maxDuration
        case duration
        case offset
        case shouldAnimate
        case isEssential
        case easing
    }
}
