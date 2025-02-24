//
//  MapStyleView.swift
//  MapTilerMobileDemo
//

import SwiftUI
import MapTilerSDK

struct MapStyleView: View {
    enum Constants {
        static let emptyString = ""
        static let defaultOpacity: CGFloat = 0.7
        static let minHeight: CGFloat = 40
    }

    @State private var referenceStyle: MTMapReferenceStyle = .streets
    @State private var styleVariant: MTMapStyleVariant? = .reference

    private var selectedStyleVariants: [MTMapStyleVariant]? {
        return referenceStyle.getVariants()
    }

    var body: some View {
        VStack {
            MTMapViewContainer(options: MTMapOptions(attributionControlIsVisible: false))
                .referenceStyle(referenceStyle)
                .styleVariant(styleVariant)

            HStack(alignment: .top) {
                Picker(Constants.emptyString, selection: $referenceStyle) {
                    ForEach(MTMapReferenceStyle.allCases) { style in
                        Text(style.rawValue.capitalized)
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
