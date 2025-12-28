//
//  SkyPresets+SwiftUI.swift
//  MapTilerSDK
//

import SwiftUI
import CoreLocation
import MapTilerSDK

struct SkyPresetsView: View {
    enum SkyPreset: String, CaseIterable, Identifiable {
        case clear = "Clear"
        case sunset = "Sunset"
        case night = "Night"
        case foggy = "Foggy"

        var id: String { rawValue }
    }

    private enum C {
        static let pacific = CLLocationCoordinate2D(latitude: -20.0, longitude: -140.0)
    }

    @State private var mapView = MTMapView(options: MTMapOptions())
    @State private var preset: SkyPreset = .clear

    init() {
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }
    }

    var body: some View {
        VStack(spacing: 12) {
            MTMapViewContainer(map: mapView) {}
                .referenceStyle(.basic)
                .styleVariant(.defaultVariant)
                .didInitialize {
                    Task { @MainActor in
                        try? await mapView.setMaxPitch(85)
                        await mapView.setVerticalFieldOfView(degrees: 45)
                        await mapView.enableTerrain(exaggerationFactor: 1.0)
                        await mapView.setIsCenterClampedToGround(false)

                        let camera = MTCameraOptions(center: C.pacific, zoom: 5.5, bearing: 0.0, pitch: 80.0)
                        await mapView.easeTo(C.pacific, options: camera, animationOptions: nil)

                        await applyCurrentPreset()
                    }
                }

            Picker("Sky", selection: $preset) {
                ForEach(SkyPreset.allCases) { p in
                    Text(p.rawValue).tag(p)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: preset) { _ in
                Task { await applyCurrentPreset() }
            }

            HStack(spacing: 12) {
                Button("Force Reload Style") {
                    Task { @MainActor in
                        await mapView.style?.forceReloadStyle()
                        await applyCurrentPreset()
                    }
                }
                Button("Horizon") {
                    Task { @MainActor in
                        let camera = MTCameraOptions(center: C.pacific, zoom: 5.5, bearing: 0.0, pitch: 80.0)
                        await mapView.easeTo(C.pacific, options: camera, animationOptions: nil)
                    }
                }
            }
        }
        .padding()
    }

    @MainActor
    private func applyCurrentPreset() async {
        let sky: MTSky
        switch preset {
        case .clear:
            sky = MTSky(
                skyColor: .color(UIColor(red: 0.60, green: 0.78, blue: 0.94, alpha: 1.0)),
                skyHorizonBlend: .number(0.35),
                horizonColor: .color(UIColor(red: 0.72, green: 0.85, blue: 0.96, alpha: 1.0)),
                horizonFogBlend: .number(0.0),
                fogColor: .color(UIColor(white: 0.92, alpha: 1.0)),
                fogGroundBlend: .number(0.0),
                atmosphereBlend: .number(0.20)
            )
        case .sunset:
            sky = MTSky(
                skyColor: .color(UIColor(red: 0.34, green: 0.19, blue: 0.45, alpha: 1.0)),
                skyHorizonBlend: .number(0.55),
                horizonColor: .color(UIColor(red: 1.00, green: 0.55, blue: 0.30, alpha: 1.0)),
                horizonFogBlend: .number(0.0),
                fogColor: .color(UIColor(white: 0.92, alpha: 1.0)),
                fogGroundBlend: .number(0.0),
                atmosphereBlend: .number(0.45)
            )
        case .night:
            sky = MTSky(
                skyColor: .color(UIColor(red: 0.02, green: 0.06, blue: 0.16, alpha: 1.0)),
                skyHorizonBlend: .number(0.25),
                horizonColor: .color(UIColor(red: 0.04, green: 0.10, blue: 0.22, alpha: 1.0)),
                horizonFogBlend: .number(0.0),
                fogColor: .color(UIColor(white: 0.90, alpha: 1.0)),
                fogGroundBlend: .number(0.0),
                atmosphereBlend: .number(0.15)
            )
        case .foggy:
            sky = MTSky(
                skyColor: .color(UIColor(red: 0.80, green: 0.83, blue: 0.85, alpha: 1.0)),
                skyHorizonBlend: .number(0.80),
                horizonColor: .color(UIColor(red: 0.88, green: 0.90, blue: 0.91, alpha: 1.0)),
                horizonFogBlend: .number(0.60),
                fogColor: .color(UIColor(white: 0.92, alpha: 1.0)),
                fogGroundBlend: .number(0.50),
                atmosphereBlend: .number(0.35)
            )
        }

        await mapView.setSky(sky, options: MTStyleSetterOptions(shouldValidate: false))
    }
}
