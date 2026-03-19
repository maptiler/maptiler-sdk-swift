//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPitchLimitHelper.swift
//  MapTilerSDK
//

/// Sets combination of minimum and maximum pitch.
public class MTPitchLimitHelper {
    /// The maximum pitch of the map (0-85).
    ///
    /// If not specified, the SDK will look for it in the map options.
    /// If not specified there, it defaults to 60.
    public var maxPitch: Double?

    /// The minimum pitch of the map (0-85).
    ///
    /// If not specified, the SDK will look for it in the map options.
    /// If not specified there, it defaults to 0.
    public var minPitch: Double?

    private init(
        maxPitch: Double? = nil,
        minPitch: Double? = nil
    ) {
        self.maxPitch = maxPitch
        self.minPitch = minPitch
    }

    /// Returns pitch limit object with no specified limits.
    public static func getPitchLimits() -> MTPitchLimitHelper {
        return MTPitchLimitHelper()
    }

    /// Returns pitch limit object constructed from given options object.
    /// - Parameters:
    ///   - options: MTMapOptions object with initial limit options.
    public static func getPitchLimitsWith(_ options: MTMapOptions) -> MTPitchLimitHelper {
        return MTPitchLimitHelper(
            maxPitch: options.maxPitch,
            minPitch: options.minPitch
        )
    }

    /// Returns pitch limit object with the given max pitch and min pitch.
    /// - Parameters:
    ///   - maxPitch: The maximum pitch of the map (0-85).
    ///   - minPitch: The minimum pitch of the map (0-85).
    public static func limitPitch(
        maxPitch: Double,
        minPitch: Double
    ) -> MTPitchLimitHelper {
        return MTPitchLimitHelper(
            maxPitch: maxPitch,
            minPitch: minPitch
        )
    }

    /// Returns pitch limit object with the given max pitch.
    /// - Parameters:
    ///   - maxPitch: The maximum pitch of the map (0-85).
    public static func limitMaxPitch(
        _ maxPitch: Double
    ) -> MTPitchLimitHelper {
        return MTPitchLimitHelper(
            maxPitch: maxPitch
        )
    }

    /// Returns pitch limit object with the given min pitch.
    /// - Parameters:
    ///   - minPitch: The minimum pitch of the map (0-85).
    public static func limitMinPitch(
        _ minPitch: Double
    ) -> MTPitchLimitHelper {
        return MTPitchLimitHelper(
            minPitch: minPitch
        )
    }
}

extension MTPitchLimitHelper {
    /// Returns a Boolean indicating whether the pitch limit object is equal to the receiver.
    /// - Parameters:
    ///   - pitchLimit: MTPitchLimitHelper object to compare with.
    public func isEqualToPitchLimitHelper(_ pitchLimit: MTPitchLimitHelper) -> Bool {
        let isMaxPitchEqual = self.maxPitch == pitchLimit.maxPitch
        let isMinPitchEqual = self.minPitch == pitchLimit.minPitch

        return isMaxPitchEqual && isMinPitchEqual
    }
}
