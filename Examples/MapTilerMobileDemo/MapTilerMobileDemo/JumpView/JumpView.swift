//
//  JumpView.swift
//  MapTilerMobileDemo
//

import SwiftUI
import CoreLocation
import Combine

class JumpDataModel: ObservableObject {
    @Published var jumpCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()

    func updateJumpCoordinates(jumpSelection: String) {
        Task {
            let geocoder = CLGeocoder()
            
            let placemarks = try await geocoder.geocodeAddressString(jumpSelection)

            var location: CLLocation?

            if placemarks.count > 0 {
                location = placemarks.first?.location
            }

            if let location = location {
                await MainActor.run {
                    jumpCoordinates = location.coordinate
                }
            }
        }
    }
}

struct JumpView: View {
    enum Constants {
        static let jumpActionTitle = "Jump"
        static let pickerPlaceholder = "Select location"
        static let defaultSpacing: CGFloat = 10.0
        static let defaultWidth: CGFloat = 90.0
        static let pickerWidth: CGFloat = 160.0
        static let defaultHeight: CGFloat = 10.0
        static let defaultCornerRadius: CGFloat = 8.0
        static let jumpActionBackgroundColor = Color(red: 0/255, green: 161/255, blue: 194/255)
    }

    private let jumpSelections = [
            "Amsterdam",
            "Lima",
            "Miami",
            "Tokyo",
            "Prague",
            "Nairobi",
            "Zürich"
        ]

    @ObservedObject var dataModel: JumpDataModel

    @State private var selected: String = Constants.pickerPlaceholder

    var body: some View {
        HStack(spacing: Constants.defaultSpacing) {
            Picker(Constants.jumpActionTitle,
                   selection: $selected,
                   content: {
                if selected == Constants.pickerPlaceholder {
                    Text(Constants.pickerPlaceholder).tag(Constants.pickerPlaceholder)
                }

                ForEach(jumpSelections, id: \.self) {
                    Text($0)
                        .accentColor(.black)
                        .foregroundStyle(.black)
                        .tint(.black)
                }
            })
            .pickerStyle(.menu)
            .tint(.white)
            .frame(maxWidth: Constants.pickerWidth, maxHeight: Constants.defaultHeight)

            Button(action: {
                dataModel.updateJumpCoordinates(jumpSelection: selected)
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
