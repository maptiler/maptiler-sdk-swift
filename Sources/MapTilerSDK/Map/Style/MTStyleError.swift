//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTStyleError.swift
//  MapTilerSDK
//

/// Represents the exceptions raised by the MTStyle object.
public enum MTStyleError: Error {
    /// Source with the same id already added to the map.
    case sourceAlreadyExists

    /// Source does not exist in the map.
    case sourceNotFound

    /// Layer with the same id already added to the map.
    case layerAlreadyExists

    /// Layer does not exist in the map.
    case layerNotFound
}
