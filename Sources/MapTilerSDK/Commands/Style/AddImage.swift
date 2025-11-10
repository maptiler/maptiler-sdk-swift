//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddImage.swift
//  MapTilerSDK
//

import Foundation
import UIKit

package struct AddImage: MTCommand {
    private let emptyReturnValue = ""

    var name: String
    var encodedImage: String
    var options: MTStyleImageOptions?

    init?(name: String, image: UIImage, options: MTStyleImageOptions?) {
        guard let encodedImage = image.getEncodedString() else {
            return nil
        }

        self.name = name
        self.encodedImage = encodedImage
        self.options = options
    }

    package func toJS() -> JSString {
        let imageVariable = makeImageVariableName()

        guard !encodedImage.isEmpty else {
            return emptyReturnValue
        }

        let optionsFragment: JSString
        if let options = options, let optionsJSON = options.toJSON() {
            optionsFragment = ", \(optionsJSON)"
        } else {
            optionsFragment = ""
        }

        return """
        var \(imageVariable) = new Image();
            \(imageVariable).src = 'data:image/png;base64,\(encodedImage)';
            \(imageVariable).onload = function() {
                \(MTBridge.mapObject).style.addImage(\(encodedName()), \(imageVariable)\(optionsFragment));
            };
        """
    }

    private func encodedName() -> String {
        guard
            let data = try? JSONEncoder().encode(name),
            let string = String(data: data, encoding: .utf8)
        else {
            return "\"\(name)\""
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
