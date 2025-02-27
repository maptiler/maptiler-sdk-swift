//
//  MTSourceData.swift
//  MapTilerSDK
//

/// The style spec representation of the source if the event has a dataType of source .
public struct MTSourceData: Codable {
    var type: String
    var url: String
}
