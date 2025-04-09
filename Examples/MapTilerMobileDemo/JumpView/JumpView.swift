//
//  JumpView.swift
//  MapTilerMobileDemo
//

import SwiftUI
import CoreLocation
import Combine

class JumpDataModel: ObservableObject {
    @Published var jumpCoordinates: CLLocationCoordinate2D?

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
        static let jumpActionBackgroundColor = Color(red: 255/255, green: 255/255, blue: 255/255)
    }

    private let jumpSelections = [
            "Amsterdam",
            "Quito",
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
            Spacer()

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
                    .foregroundColor(.gray)
                    .cornerRadius(Constants.defaultCornerRadius)
            }
            .padding()
        }
        .background(.clear)
        .padding()
    }
}
