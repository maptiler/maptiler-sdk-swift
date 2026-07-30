//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTCommand.swift
//  MapTilerSDK
//

public typealias JSString = String

public protocol MTCommand: Sendable {
    func toJS() -> JSString
}

package protocol MTCommandExecutable {
    func execute(_ command: MTCommand) async throws -> MTBridgeReturnType
}
