//
//  MTBridgeError.swift
//  MapTilerSDK
//

public enum MTBridgeError: Error {
    case exception(String)
    case invalidResultType(String)
    case unsupportedReturnType(String)
    case unknown(String)
    case bridgeNotLoaded
}
