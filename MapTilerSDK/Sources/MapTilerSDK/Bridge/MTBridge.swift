//
//  MTBridge.swift
//  MapTilerSDK
//

import Foundation

// Class responsible for bridging external implementations and Swift code
// It uses abstract executor as mediator object allowing outside executor implementations
package final class MTBridge: @unchecked Sendable {
    var executor: MTCommandExecutable?

    static let mapObject: JSString = "map"
    static let sdkObject: JSString = "maptilersdk"
    static let styleObject: JSString = "MapStyle"

    init(executor: MTCommandExecutable) {
        self.executor = executor
    }

    func execute(_ command: MTCommand) async throws -> MTBridgeReturnType? {
        return try await executor?.execute(command)
    }
}
