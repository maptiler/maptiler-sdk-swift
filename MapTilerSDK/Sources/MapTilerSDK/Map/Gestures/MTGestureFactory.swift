//
//  MTGestureFactory.swift
//  MapTilerSDK
//

package class MTGestureFactory {
    package static func makeGesture(with type: MTGestureType) -> MTGesture {
        switch type {
        case .doubleTapZoomIn:
            return MTDoubleTapZoomInGesture()
        case .dragPan:
            return MTDragPanGesture()
        case .twoFingersDragPitch:
            return MTTwoFingersDragPitchGesture()
        case .pinchRotateAndZoom:
            return MTPinchRotateAndZoomGesture()
        }
    }
}
