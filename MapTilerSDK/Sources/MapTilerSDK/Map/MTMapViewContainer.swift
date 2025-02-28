//
//  MTMapViewContainer.swift
//  MapTilerSDK
//

import SwiftUI

/// Declarative Map view for use in SwiftUI
public struct MTMapViewContainer: View {
    @State private var coordinator: MTCoordinator? = MTCoordinator()
    private var options: MTMapOptions?

    private var referenceStyle: MTMapReferenceStyle = .streets
    private var styleVariant: MTMapStyleVariant?

    public init(options: MTMapOptions?) {
        self.options = options
    }

    public var body: some View {
        MTMapViewRepresentable(
            options: options,
            coordinator: coordinator,
            referenceStyle: referenceStyle,
            styleVariant: styleVariant
        )
    }
}

package struct MTMapViewRepresentable: UIViewRepresentable {
    private let notInitializedMessage: String = "MapView not initialized yet!"

    private var referenceStyle: MTMapReferenceStyle = .streets
    private var styleVariant: MTMapStyleVariant?

    private var options: MTMapOptions?

    private var coordinator: MTCoordinator?

    public init(
        options: MTMapOptions?,
        coordinator: MTCoordinator?,
        referenceStyle: MTMapReferenceStyle,
        styleVariant: MTMapStyleVariant?
    ) {
        self.referenceStyle = referenceStyle
        self.styleVariant = styleVariant
        self.options = options
        self.coordinator = coordinator
    }

    public func makeUIView(context: Context) -> some UIView {
        let mapView = MTMapView(options: options)
        mapView.setProxy(referenceStyle: referenceStyle, styleVariant: styleVariant)

        mapView.delegate = coordinator

        updateMapView(mapView)

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
}

package class MTCoordinator: MTMapViewDelegate {
    var didTriggerEvent: ((MTEvent, MTData?) -> Void)?
    var didInitialize: (() -> Void)?

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
}
