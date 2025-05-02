//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTGestureType.swift
//  MapTilerSDK
//

/// Gesture types available in the SDK.
@MainActor
public enum MTGestureType {
    /// Double tap zoom in.
    case doubleTapZoomIn

    /// Drag and pan.
    case dragPan

    /// Pitch shifting with two finger drag.
    case twoFingersDragPitch

    /// Pinching to rotate and zoom.
    case pinchRotateAndZoom
}
