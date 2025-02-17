//
//  JumpTo.swift
//  MapTilerSDK
//

import CoreLocation

package struct JumpTo: MTCommand {
    var center: CLLocationCoordinate2D
    var options: MTCameraOptions?

    package func toJS() -> JSString {
        let options = JumpToOptions(center: center, options: options)
        let optionsString: JSString = options.toJSON() ?? ""

        return "\(MTBridge.shared.mapObject).jumpTo(\(optionsString));"
    }
}

package struct JumpToOptions: Codable {
    var center: CLLocationCoordinate2D
    var options: MTCameraOptions?

    package init(center: CLLocationCoordinate2D, options: MTCameraOptions?) {
        self.center = center
        self.options = options
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.center = try container.decode(CLLocationCoordinate2D.self, forKey: .center)
        self.options = try MTCameraOptions(from: decoder)
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
    }

    package enum CodingKeys: String, CodingKey {
        case center
        case bearing
        case pitch
        case zoom
    }
}
