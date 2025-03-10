//
//  DecimaleCoordinateFormatter.swift
//  MapTilerMobileDemo
//
import Foundation

class DecimalCoordinateFormatter: Formatter {
    private let numberFormatter: NumberFormatter

    override init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 6
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.decimalSeparator = "."

        super.init()
    }

    required init?(coder: NSCoder) {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 6
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.decimalSeparator = "."

        super.init(coder: coder)
    }

    override func string(for obj: Any?) -> String? {
        guard let value = obj as? Double else {
            return nil
        }

        return numberFormatter.string(from: NSNumber(value: value))
    }

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        let formattedString = string.replacingOccurrences(of: ",", with: ".")

        if let value = numberFormatter.number(from: formattedString)?.doubleValue {
            obj?.pointee = value as AnyObject
            return true
        } else {
            return false
        }
    }
}
