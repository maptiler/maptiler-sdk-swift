//
//  FlyTo.swift
//  MapTilerSDK
//

import CoreLocation

package struct FlyTo: MTCommand {
    var center: CLLocationCoordinate2D
    var options: MTFlyToOptions?

    package func toJS() -> JSString {
        let options = FlyToOptions(center: center, options: options)
        let optionsString: JSString = options.toJSON() ?? ""

        return "\(MTBridge.shared.mapObject).flyTo(\(optionsString));"
    }
}

package struct FlyToOptions: Codable {
    var center: CLLocationCoordinate2D
    var options: MTFlyToOptions?

    package init(center: CLLocationCoordinate2D, options: MTFlyToOptions?) {
        self.center = center
        self.options = options
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.center = try container.decode(CLLocationCoordinate2D.self, forKey: .center)
        self.options = try MTFlyToOptions(from: decoder)
    }

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
    }

    package enum CodingKeys: String, CodingKey {
        case center
        case curve
        case minZoom
        case speed
        case screenSpeed
        case maxDuration
    }
}
