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
                downloadState = "Downloading..."
            }

            try await pack.download()

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

            // Jump to the downloaded region
            await mapView.jumpTo(
                CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417),
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

                HStack(spacing: 20) {
                    Button("Download Zurich") {
                        Task { await viewModel.downloadRegion() }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Load Offline Pack") {
                        Task { await viewModel.loadPack() }
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.offlinePack == nil || viewModel.downloadProgress < 1.0)
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
