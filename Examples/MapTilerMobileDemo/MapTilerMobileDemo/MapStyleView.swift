//
//  MapStyleView.swift
//  MapTilerMobileDemo
//

import SwiftUI
import MapTilerSDK

struct MapStyleView: View {
    enum Constants {
        static let referenceStylePickerTitle = "Reference Style:"
        static let styleVariantPickerTitle = "Style Variant:"
        static let emptyString = ""
        static let defaultOpacity: CGFloat = 0.7
        static let minHeight: CGFloat = 300
        static let widthOffset: CGFloat = 0.85
        static let heightOffset: CGFloat = 0.7
    }

    @State private var referenceStyle: MTMapReferenceStyle = .streets
    @State private var styleVariant: MTMapStyleVariant? = .light

    private var selectedStyleVariants: [MTMapStyleVariant] {
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
                        Text(Constants.referenceStylePickerTitle)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(.top)

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
                        .pickerStyle(.wheel)
                        .tint(.white)
                        .onChange(of: referenceStyle) { _ in
                            if let variant = selectedStyleVariants.first {
                                styleVariant = variant
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }

                    VStack {
                        Text(Constants.styleVariantPickerTitle)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(.top)

                        Picker(Constants.emptyString, selection: $styleVariant) {
                            ForEach(selectedStyleVariants) { style in
                                Text(style.rawValue.capitalized)
                                    .accentColor(.white)
                                    .foregroundStyle(.white)
                                    .tint(.white)
                                    .opacity(Constants.defaultOpacity)
                                    .tag(style)
                            }
                        }
                        .pickerStyle(.wheel)
                        .tint(.white)
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
                .frame(maxWidth: geometry.size.width * Constants.widthOffset, minHeight: Constants.minHeight)
                .ignoresSafeArea()
            }
        }
    }
}
