//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTGestureFactory.swift
//  MapTilerSDK
//

package class MTGestureFactory {
    @MainActor
    package static func makeGesture(with type: MTGestureType, bridge: MTBridge) -> MTGesture {
        switch type {
        case .doubleTapZoomIn:
            return MTDoubleTapZoomInGesture(bridge: bridge)
        case .dragPan:
            return MTDragPanGesture(bridge: bridge)
        case .twoFingersDragPitch:
            return MTTwoFingersDragPitchGesture(bridge: bridge)
        case .pinchRotateAndZoom:
            return MTPinchRotateAndZoomGesture(bridge: bridge)
        }
    }
}
