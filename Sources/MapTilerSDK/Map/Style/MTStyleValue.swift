//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTStyleValue.swift
//  MapTilerSDK
//

import UIKit

/// A unified style value that may be a constant or an expression.
public enum MTStyleValue: Sendable {
    case color(UIColor)
    case number(Double)
    case bool(Bool)
    case string(String)
    case expression(MTPropertyValue)
}
