//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddPopup.swift
//  MapTilerSDK
//

package struct AddTextPopup: MTCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        struct Options: Encodable {
            let offset: Double
            let maxWidth: Double?

            enum CodingKeys: String, CodingKey {
                case offset
                case maxWidth
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(offset, forKey: .offset)

                if let maxWidth {
                    try container.encode(maxWidth, forKey: .maxWidth)
                }
            }
        }

        let options = Options(offset: popup.offset ?? 0, maxWidth: popup.maxWidth)
        let optionsString = options.toJSON() ?? "{}"
        let coordinates = popup.coordinates.toLngLat()

        return """
            const \(popup.identifier) = new maptilersdk.Popup(\(optionsString));

            \(popup.identifier)
            .setLngLat([\(coordinates.lng), \(coordinates.lat)])
            .setText('\(popup.text)')
            .addTo(\(MTBridge.mapObject));
            """
    }
}
