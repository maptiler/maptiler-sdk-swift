//
//  MTLog.swift
//  MapTilerSDK
//

/// Log object used with MTLogger.
public struct MTLog {
    public var message: String
    public var type: MTLogType

    public func printLog() {
        print("\(type): \(message)")
    }
}
