//
//  MTBridgeReturnType.swift
//  MapTilerSDK
//

package enum MTBridgeReturnType: Sendable {
    case string(String)
    case double(Double)
    case bool(Bool)
    case unsupportedType
    case null

    init(from value: Any?) throws {
        if let value = value as? String {
            self = .string(value)
        } else if let value = value as? Double {
            self = .double(value)
        } else if let value = value as? Bool {
            self = .bool(value)
        } else if value == nil {
            self = .null
        } else {
            throw MTError.invalidResultType(description: value.debugDescription)
        }
    }
}
