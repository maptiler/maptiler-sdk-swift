//
//  JumpView.swift
//  MapTilerMobileDemo
//

import SwiftUI
import CoreLocation
import Combine

class JumpDataModel: ObservableObject {
    let initialCoordinate = 0.000000

    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var jumpCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()

    func updateJumpCoordinates() {
        jumpCoordinates = CLLocationCoordinate2D(latitude: latitude ?? initialCoordinate, longitude: longitude ?? initialCoordinate)
    }
}

struct JumpView: View {
    enum Constants {
        static let latitudeTitle = "Lat"
        static let longitudeTitle = "Lng"
        static let jumpActionTitle = "Jump"
        static let defaultSpacing: CGFloat = 10.0
        static let defaultWidth: CGFloat = 100.0
        static let defaultHeight: CGFloat = 10.0
        static let defaultTextFieldHeight: CGFloat = 30.0
        static let defaultCornerRadius: CGFloat = 8.0
        static let jumpActionBackgroundColor = Color(red: 0/255, green: 161/255, blue: 194/255)
    }

    private enum Field: Int, CaseIterable {
            case latitude, longitude
        }

    @ObservedObject var dataModel: JumpDataModel
    @FocusState private var focusedField: Field?

    var body: some View {
        HStack(spacing: Constants.defaultSpacing) {
            TextField(Constants.latitudeTitle, value: $dataModel.latitude, formatter: DecimalCoordinateFormatter())
                .textFieldStyle(.plain)
                .keyboardType(.decimalPad)
                .frame(width: Constants.defaultWidth)
                .focused($focusedField, equals: .latitude)
                .foregroundStyle(.black)
                .frame(height: Constants.defaultTextFieldHeight)
                .background(.white)
                .cornerRadius(Constants.defaultCornerRadius)

            TextField(Constants.longitudeTitle, value: $dataModel.longitude, formatter: DecimalCoordinateFormatter())
                .textFieldStyle(.plain)
                .keyboardType(.decimalPad)
                .frame(width: Constants.defaultWidth)
                .focused($focusedField, equals: .longitude)
                .foregroundStyle(.black)
                .frame(height: Constants.defaultTextFieldHeight)
                .background(.white)
                .cornerRadius(Constants.defaultCornerRadius)

            Button(action: {
                dataModel.updateJumpCoordinates()
                focusedField = nil
            }) {
                Text(Constants.jumpActionTitle)
                    .bold()
                    .frame(maxWidth: Constants.defaultWidth, maxHeight: Constants.defaultHeight)
                    .padding()
                    .background(Constants.jumpActionBackgroundColor)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.defaultCornerRadius)
            }
        }
        .background(.clear)
        .padding()
    }
}
