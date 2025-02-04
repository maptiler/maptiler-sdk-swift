//
//  MTBridgeFactory.swift
//  MapTilerSDK
//

package final class MTBridgeFactory {
    static func makeBridge(with executor: MTCommandExecutable) -> MTBridge {
        return MTBridge(executor: executor)
    }
}
