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
        static let maxHeight: CGFloat = 100
        static let widthOffset: CGFloat = 0.85
        static let heightOffset: CGFloat = 0.9
    }

    @State private var referenceStyle: MTMapReferenceStyle = .streets
    @State private var styleVariant: MTMapStyleVariant? = .reference

    private var selectedStyleVariants: [MTMapStyleVariant]? {
        return referenceStyle.getVariants()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                MTMapViewContainer(options: MTMapOptions(attributionControlIsVisible: false))
                    .referenceStyle(referenceStyle)
                    .styleVariant(styleVariant)
                    .frame(maxHeight: geometry.size.height * Constants.heightOffset)
                    .ignoresSafeArea()

                HStack(alignment: .top) {
                    VStack {
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
                        .frame(maxHeight: .infinity, alignment: .top)
                    }

                    VStack {
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
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
                .frame(maxWidth: geometry.size.width * Constants.widthOffset, maxHeight: Constants.maxHeight)
                .ignoresSafeArea()
            }
        }
    }
}
