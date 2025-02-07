//
//  MTBridge.swift
//  MapTilerSDK
//

import Foundation

// Class responsible for bridging external implementations and Swift code
// It uses abstract executor as mediator object allowing outside executor implementations
package final class MTBridge: @unchecked Sendable {
    static let shared = MTBridge()

    var executor: MTCommandExecutable?
    private var queue: DispatchQueue = DispatchQueue(label: "com.bridge.queue")

    let mapObject: JSString = "map"

    private init() {}

    func setExecutor(_ executor: MTCommandExecutable) {
        self.executor = executor
    }

    func execute(_ command: MTCommand) async {
        queue.async { [weak self] in
            Task {
                await self?.executor?.execute(command)
            }
        }
    }
}
