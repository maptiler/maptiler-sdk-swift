//
//  MTCommand.swift
//  MapTilerSDK
//

package typealias JSString = String

package protocol MTCommand: Sendable {
    static var instance: MTCommand { get }
    func toJS() -> JSString
}

package protocol MTCommandExecutable {
    func execute(_ command: MTCommand) async
}
