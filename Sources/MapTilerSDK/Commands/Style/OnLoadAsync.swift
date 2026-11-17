//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  OnLoadAsync.swift
//  MapTilerSDK
//

package struct OnLoadAsync: MTCommand {
    package func toJS() -> JSString {
        return "await \(MTBridge.mapObject).onLoadAsync();"
    }
}
