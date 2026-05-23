//
//  OfflineBasic+SwiftUI.swift
//  MapTilerMobileDemo
//

import SwiftUI
import MapTilerSDK
import CoreLocation

class OfflineViewModel: ObservableObject, MTOfflineDownloadDelegate {
    @Published var downloadProgress: Float = 0.0
    @Published var downloadState: String = "Idle"
    @Published var offlinePack: MTOfflinePack?

    var mapView = MTMapView(options: MTMapOptions())

    init() {
        Task {
            do {
                let packs = try await MTOfflinePack.packs()
                if let firstPack = packs.first {
                    let packState = await firstPack.state
                    await MainActor.run {
                        self.offlinePack = firstPack
                        if packState == .completed {
                            self.downloadState = "Pack ready on disk"
                            self.downloadProgress = 1.0
                        } else {
                            self.downloadState = "Pack partially downloaded"
                        }
                    }
                }
            } catch {
                print("Failed to load existing offline packs: \(error)")
            }
        }
    }

    func downloadRegion() async {
        await MainActor.run {
            downloadState = "Estimating..."
            downloadProgress = 0.0
        }

        // Define the region: Zurich, Switzerland
        let zurichBBox = MTBoundingBox(
            minLon: 8.448,
            minLat: 47.320,
            maxLon: 8.625,
            maxLat: 47.434
        )

        // Automatically fetch the current map style ID and build the definition
        let region = await mapView.createOfflineRegion(
            bbox: zurichBBox,
            minZoom: 10,
            maxZoom: 14
        )

        // Add a context dictionary so we can store custom metadata like the name
        let contextData = try? JSONEncoder().encode(["name": "Zurich Offline"])

        do {
            // Increase the global limit if necessary
            await MTConfig.shared.setOfflineMaxTileCount(25000)

            let pack = MTOfflinePack(region: region, context: contextData)
            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            await MainActor.run {
                self.offlinePack = pack
                downloadState = "Downloading Zurich..."
            }

            try await pack.download()

        } catch {
            await MainActor.run {
                downloadState = "Error: \(error.localizedDescription)"
                print("Download failed: \(error)")
            }
        }
    }

    func downloadBrnoBackground() async {
        await MainActor.run {
            downloadState = "Estimating..."
            downloadProgress = 0.0
        }

        // Define the region: Brno, Czech Republic
        let brnoBBox = MTBoundingBox(
            minLon: 16.52,
            minLat: 49.13,
            maxLon: 16.70,
            maxLat: 49.25
        )

        let region = await mapView.createOfflineRegion(
            bbox: brnoBBox,
            minZoom: 10,
            maxZoom: 14
        )

        let contextData = try? JSONEncoder().encode(["name": "Brno Offline"])

        do {
            await MTConfig.shared.setOfflineMaxTileCount(25000)

            let pack = MTOfflinePack(region: region, context: contextData)
            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            await MainActor.run {
                self.offlinePack = pack
                downloadState = "Downloading Brno in Background..."
            }

            // Important: useBackground flag set to true!
            try await pack.download(useBackground: true)

        } catch {
            await MainActor.run {
                downloadState = "Error: \(error.localizedDescription)"
                print("Download failed: \(error)")
            }
        }
    }

    func loadPack() async {
        guard let pack = offlinePack else { return }

        await MainActor.run {
            downloadState = "Loading offline style..."
        }

        do {
            // Load the downloaded pack into the map
            try await mapView.loadOfflinePack(pack)

            var center = CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417)
            if let contextData = await pack.metadata.context,
                let contextDict = try? JSONDecoder().decode([String: String].self, from: contextData),
                contextDict["name"] == "Brno Offline" {
                center = CLLocationCoordinate2D(latitude: 49.1951, longitude: 16.6068)
            }

            // Jump to the downloaded region
            await mapView.jumpTo(
                center,
                options: MTCameraOptions(zoom: 12)
            )

            await MainActor.run {
                downloadState = "Loaded Offline Pack!"
            }
        } catch {
            await MainActor.run {
                downloadState = "Failed to load pack: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - MTOfflineDownloadDelegate

    func offlinePack(_ id: String, didUpdateProgress progress: MTOfflinePackProgress) {
        DispatchQueue.main.async {
            self.downloadProgress = Float(progress.percentage)
        }
    }

    func offlinePack(_ id: String, didChangeState state: MTOfflinePackState) {
        DispatchQueue.main.async {
            if state == .completed {
                self.downloadState = "Download Complete!"
                self.downloadProgress = 1.0
            } else if state == .failed {
                self.downloadState = "Download Failed!"
            }
        }
    }

    func offlinePack(_ id: String, didReceiveError error: Error) {
        DispatchQueue.main.async {
            self.downloadState = "Error: \(error.localizedDescription)"
        }
    }

    func offlinePack(_ pack: String, didFailResource error: MTOfflineError, context: MTOfflineContext) {}
    func offlinePack(_ pack: String, didSucceedResource context: MTOfflineContext) {}
}

struct OfflineBasicView: View {
    @StateObject private var viewModel = OfflineViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            MTMapViewContainer(map: viewModel.mapView) {
                // Empty content
            }
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                Text("Offline Region Download")
                    .font(.headline)
                    .padding(.top)

                if viewModel.downloadProgress > 0 && viewModel.downloadProgress < 1 {
                    ProgressView(value: viewModel.downloadProgress)
                        .progressViewStyle(.linear)
                        .padding(.horizontal)
                }

                Text("Status: \(viewModel.downloadState)")
                    .font(.subheadline)

                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        VStack {
                            Button("Download Zurich") {
                                Task { await viewModel.downloadRegion() }
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Load Zurich") {
                                Task { await viewModel.loadPack() }
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.offlinePack == nil || viewModel.downloadProgress < 1.0)
                        }

                        VStack {
                            Button("Download Brno (BG)") {
                                Task { await viewModel.downloadBrnoBackground() }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)

                            Button("Load Brno") {
                                Task { await viewModel.loadPack() }
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.offlinePack == nil || viewModel.downloadProgress < 1.0)
                        }
                    }
                }
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .cornerRadius(16)
            .padding()
        }
    }
}
