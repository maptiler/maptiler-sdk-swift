//
//  MapStyleView.swift
//  MapTilerMobileDemo
//

import SwiftUI
import MapTilerSDK
import CoreLocation

struct MapStyleView: View {
    enum Constants {
        static let emptyString = ""
        static let defaultOpacity: CGFloat = 0.7
        static let minHeight: CGFloat = 40

        static let unterageriCoordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
        static let brnoCoordinates = CLLocationCoordinate2D(latitude: 49.212596, longitude: 16.626576)
    }

    @State private var referenceStyle: MTMapReferenceStyle = .basic
    @State private var styleVariant: MTMapStyleVariant? = .defaultVariant

    @State private var map = MTMapView(options: MTMapOptions())

    private var selectedStyleVariants: [MTMapStyleVariant]? {
        return referenceStyle.getVariants()
    }

    var body: some View {
        VStack {
            MTMapViewContainer(map: map) {
                MTMarker(coordinates: Constants.brnoCoordinates, color: .magenta, draggable: true)

                let maptilerPopup = MTTextPopup(coordinates: Constants.unterageriCoordinates, text: "MapTiler")
                MTMarker(coordinates: Constants.unterageriCoordinates, icon: UIImage(named: "maptiler-marker"))
                    .popup(maptilerPopup)
            }
                .referenceStyle(referenceStyle)
                .styleVariant(styleVariant)
                .didInitialize {
                    print("-------------------------")
                    print(">>> MapTiler SDK Demo <<<")
                    print("--- Map Initialized ---")
                    print("-------------------------")
                }

            HStack(alignment: .top) {
                Picker(Constants.emptyString, selection: $referenceStyle) {
                    ForEach(MTMapReferenceStyle.all()) { style in
                        Text(style.getName())
                            .accentColor(.white)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .opacity(Constants.defaultOpacity)
                            .tag(style)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)
                .onChange(of: referenceStyle) { _ in
                    styleVariant = nil

                    if let variant = selectedStyleVariants?.first {
                        styleVariant = variant
                    }
                }
                .frame(height: Constants.minHeight, alignment: .top)

                Picker(Constants.emptyString, selection: $styleVariant) {
                    if let selectedStyleVariants = selectedStyleVariants {
                        ForEach(selectedStyleVariants) { style in
                            Text(style.rawValue.capitalized)
                                .accentColor(.white)
                                .foregroundStyle(.white)
                                .tint(.white)
                                .opacity(Constants.defaultOpacity)
                                .tag(style)
                        }
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)
                .disabled(selectedStyleVariants?.isEmpty ?? false)
                .frame(height: Constants.minHeight, alignment: .top)
            }
        }
    }
}
