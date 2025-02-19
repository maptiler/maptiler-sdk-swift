//
//  MTMapViewContainer.swift
//  MapTilerSDK
//

import SwiftUI

/// Declarative Map view for use in SwiftUI
public struct MTMapViewContainer: UIViewRepresentable {
    private var referenceStyle: MTMapReferenceStyle = .streets
    private var styleVariant: MTMapStyleVariant?

    public init() {
        self.referenceStyle = .streets
        self.styleVariant = .light
    }

    public func makeUIView(context: Context) -> some UIView {
        let mapView = MTMapView()

        updateMapView(mapView)

        return mapView
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let mapView = uiView as? MTMapView else {
            return
        }

        updateMapView(mapView)
    }

    private func updateMapView(_ mapView: MTMapView) {
        Task {
            await mapView.setStyle(referenceStyle, styleVariant: styleVariant)
        }
    }
}

extension MTMapViewContainer {
    public func referenceStyle(_ style: MTMapReferenceStyle) -> MTMapViewContainer {
        var view = self
        view.referenceStyle = style
        return view
    }

    public func styleVariant(_ variant: MTMapStyleVariant?) -> MTMapViewContainer {
        var view = self
        view.styleVariant = variant
        return view
    }
}
