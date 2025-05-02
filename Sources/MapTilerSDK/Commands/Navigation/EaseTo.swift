//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  EaseTo.swift
//  MapTilerSDK
//

import CoreLocation

package struct EaseTo: MTCommand {
    var center: CLLocationCoordinate2D
    var options: MTCameraOptions?
    var animationOptions: MTAnimationOptions?

    package func toJS() -> JSString {
        let options = EaseToOptions(center: center, options: options, animationOptions: animationOptions)
        var optionsString: JSString = options.toJSON() ?? ""

        optionsString = optionsString.replaceEasing()

        return "\(MTBridge.mapObject).easeTo(\(optionsString));"
    }
}

extension String {
    package func replaceEasing() -> String {
        let patternToReplace = #"("easing":\s*)"([^"]*)""#
        return self.replacingOccurrences(
            of: patternToReplace,
            with: #"$1$2"#,
            options: .regularExpression
        )
    }
}

package struct EaseToOptions: Codable {
    var center: CLLocationCoordinate2D
    var options: MTCameraOptions?
    var animationOptions: MTAnimationOptions?

    package init(center: CLLocationCoordinate2D, options: MTCameraOptions?, animationOptions: MTAnimationOptions?) {
        self.center = center
        self.options = options
        self.animationOptions = animationOptions
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.center = try container.decode(CLLocationCoordinate2D.self, forKey: .center)
        self.options = try MTCameraOptions(from: decoder)
        self.animationOptions = try MTAnimationOptions(from: decoder)
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(center, forKey: .center)

        if let bearing = options?.bearing {
            try container.encode(bearing, forKey: .bearing)
        }

        if let pitch = options?.pitch {
            try container.encode(pitch, forKey: .pitch)
        }

        if let zoom = options?.zoom {
            try container.encode(zoom, forKey: .zoom)
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

    package enum CodingKeys: String, CodingKey {
        case center
        case bearing
        case pitch
        case zoom
        case duration
        case offset
        case shouldAnimate
        case isEssential
        case easing
    }
}
