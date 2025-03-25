//
//  Image.swift
//  MapTilerSDK
//

import UIKit

extension UIImage {
    func getEncodedString() -> String? {
        func encodeString(from data: Data) -> String {
            let base64EncodedString = data.base64EncodedString(options: .lineLength64Characters)
            let encodedImageString = base64EncodedString.replacingOccurrences(
                of: "\\",
                with: "\\\\'"
            ).replacingOccurrences(
                of: "'",
                with: "\\'"
            ).replacingOccurrences(
                of: "\"",
                with: "\\\""
            ).replacingOccurrences(
                of: "\n",
                with: "\\n"
            ).replacingOccurrences(
                of: "\r",
                with: "\\r"
            )

            return encodedImageString
        }

        if let pngData = self.pngData() {
            return encodeString(from: pngData)
        } else if let jpgData = self.jpegData(compressionQuality: 1.0) {
            return encodeString(from: jpgData)
        } else {
            return nil
        }
    }
}
