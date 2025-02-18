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
    }

    @State private var referenceStyle: MTMapReferenceStyle = .streets
    @State private var styleVariant: MTMapStyleVariant? = .dark

    private var selectedStyleVariants: [MTMapStyleVariant] {
        return referenceStyle.getVariants()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                MTMapViewContainer()
                    .referenceStyle(referenceStyle)
                    .styleVariant(styleVariant)
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.7)
                    .ignoresSafeArea()

                HStack {
                    VStack {
                        Text(Constants.referenceStylePickerTitle)
                            .font(.headline)
                            .padding(.top)
                        Picker(Constants.emptyString, selection: $referenceStyle) {
                            ForEach(MTMapReferenceStyle.allCases) { style in
                                Text(style.rawValue.capitalized)
                                    .accentColor(.black)
                                    .foregroundStyle(.black)
                                    .tint(.black)
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
                    }
                    VStack {
                        Text(Constants.styleVariantPickerTitle)
                            .font(.headline)
                            .padding(.top)
                        Picker(Constants.emptyString, selection: $styleVariant) {
                            ForEach(selectedStyleVariants) { style in
                                Text(style.rawValue.capitalized)
                                    .accentColor(.black)
                                    .foregroundStyle(.black)
                                    .tint(.black)
                                    .tag(style)
                            }
                        }
                        .pickerStyle(.wheel)
                        .tint(.white)
                    }
                }
            }
        }
    }
}
