//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  UpdateImage.swift
//  MapTilerSDK
//

import Foundation
import UIKit

package struct UpdateImage: MTCommand {
    private let emptyReturnValue = ""

    var name: String
    var encodedImage: String

    init?(name: String, image: UIImage) {
        guard let encodedImage = image.getEncodedString() else {
            return nil
        }

        self.name = name
        self.encodedImage = encodedImage
    }

    package func toJS() -> JSString {
        let imageVariable = makeImageVariableName()

        guard !encodedImage.isEmpty else {
            return emptyReturnValue
        }

        return """
        var \(imageVariable) = new Image();
            \(imageVariable).src = 'data:image/png;base64,\(encodedImage)';
            \(imageVariable).onload = function() {
                \(MTBridge.mapObject).updateImage(\(encodedName()), \(imageVariable));
            };
        """
    }

    private func encodedName() -> String {
        guard
            let data = try? JSONEncoder().encode(name),
            let string = String(data: data, encoding: .utf8)
        else {
            return "\(name)"
        }

        return string
    }

    private func makeImageVariableName() -> String {
        let allowedScalars = name.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }
        let suffix = String(allowedScalars)

        if suffix.isEmpty {
            let identifier = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            return "image\(identifier)"
        }

        return "image\(suffix)"
    }
}
