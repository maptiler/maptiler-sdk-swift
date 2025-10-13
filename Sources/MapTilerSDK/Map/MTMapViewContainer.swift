//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapViewContainer.swift
//  MapTilerSDK
//

import SwiftUI
import CoreLocation

/// Declarative Map view for use in SwiftUI
public struct MTMapViewContainer: View {
    let content: [MTMapViewContent]

    @State private var coordinator: MTCoordinator? = MTCoordinator()

    private var referenceStyle: MTMapReferenceStyle = .streets
    private var styleVariant: MTMapStyleVariant?

    public var map: MTMapView

    public init(map: MTMapView, @MTMapContentBuilder content: () -> [MTMapViewContent]) {
        self.map = map
        self.content = content()
    }

    public var body: some View {
        MTMapViewRepresentable(
            map: map,
            content: content,
            coordinator: coordinator,
            referenceStyle: referenceStyle,
            styleVariant: styleVariant
        )
    }
}

package struct MTMapViewRepresentable: UIViewRepresentable {
    let content: [MTMapViewContent]

    private let notInitializedMessage: String = "MapView not initialized yet!"

    private var referenceStyle: MTMapReferenceStyle = .streets
    private var styleVariant: MTMapStyleVariant?

    private var coordinator: MTCoordinator?

    var mapView: MTMapView

    public init(
        map: MTMapView,
        content: [MTMapViewContent],
        coordinator: MTCoordinator?,
        referenceStyle: MTMapReferenceStyle,
        styleVariant: MTMapStyleVariant?
    ) {
        self.mapView = map
        self.content = content
        self.referenceStyle = referenceStyle
        self.styleVariant = styleVariant
        self.coordinator = coordinator
    }

    public func makeUIView(context: Context) -> some UIView {
        mapView.setProxy(referenceStyle: referenceStyle, styleVariant: styleVariant)

        mapView.delegate = coordinator

        mapView.didInitialize = {
            let sources = content.filter { $0 is MTSource }

            for item in sources {
                if let item = item as? MTSource {
                    mapView.style?.addSource(item)
                }
            }

            let layers = content.filter { $0 is MTLayer }

            for item in layers {
                if let item = item as? MTLayer {
                    mapView.style?.addLayer(item) { result in
                        switch result {
                        case .success:
                            MTLogger.log("Added layer with id \(item.identifier)", type: .info)
                        case .failure:
                            mapView.style?.addLayer(item)
                        }

                    }
                }
            }

            for item in content where !((item is MTSource) || (item is MTLayer)) {
                item.addToMap(mapView)
            }
        }

        return mapView
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let mapView = uiView as? MTMapView else {
            MTLogger.log(notInitializedMessage, type: .warning)
            return
        }

        updateMapView(mapView)
    }

    private func updateMapView(_ mapView: MTMapView) {
        if !mapView.isInitialized {
            MTLogger.log(notInitializedMessage, type: .warning)
            return
        }

        Task {
            await mapView.style?.setStyle(referenceStyle, styleVariant: styleVariant)

            // Re-apply space after style changes. setStyle() may override space
            // to transparent when style metadata lacks maptiler.space.
            if let space = mapView.options?.space {
                await mapView.setSpace(space)
            }
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

    public func didTriggerEvent(_ closure: @escaping (_ event: MTEvent, _ data: MTData?) -> Void) -> Self {
        coordinator?.didTriggerEvent = closure
        return self
    }

    public func didInitialize(_ closure: @escaping () -> Void) -> Self {
        coordinator?.didInitialize = closure
        return self
    }

    public func didUpdateLocation(_ closure: @escaping (_ location: CLLocation) -> Void) -> Self {
        coordinator?.didUpdateLocation = closure
        return self
    }
}

package class MTCoordinator: MTMapViewDelegate {
    var didTriggerEvent: ((MTEvent, MTData?) -> Void)?
    var didInitialize: (() -> Void)?
    var didUpdateLocation: ((CLLocation) -> Void)?

    public func mapViewDidInitialize(_ mapView: MTMapView) {
        DispatchQueue.main.async { [weak self] in
            self?.didInitialize?()
        }
    }

    public func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?) {
        DispatchQueue.main.async { [weak self] in
            self?.didTriggerEvent?(event, data)
        }
    }

    public func mapView(_ mapView: MTMapView, didUpdateLocation location: CLLocation) {
        DispatchQueue.main.async { [weak self] in
            self?.didUpdateLocation?(location)
        }
    }
}
