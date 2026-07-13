import SwiftUI
import MapTilerSDK
import CoreLocation

/// Class responsible for handling the lifecycle and state of an offline pack download.
/// Conforms to `MTOfflineDownloadDelegate`
@MainActor
class BasicOfflineDownloadManager: ObservableObject, MTOfflineDownloadDelegate {
    @Published var progress: Float = 0.0
    @Published var state: MTOfflinePackState = .pending
    @Published var currentPack: MTOfflinePack?

    /// Initiates a download of the provided geographical bounds.
    func downloadArea(bounds: MTBounds) async {
        do {
            // Clear previous pack if it exists
            if currentPack != nil {
                await clear()
            }

            // Define the region using the current map bounds
            let definition = MTOfflineRegionDefinition(
                geometry: .boundingBox(MTBoundingBox(bounds: bounds)),
                minZoom: 1,
                maxZoom: 14,
                referenceStyle: .streets
            )

            // Create the offline pack
            let pack = try await MTOfflinePack.createPack(region: definition)
            self.currentPack = pack

            // Configure the delegate to receive progress updates
            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            // Start the download process
            try await pack.download()
        } catch {
            print("Download failed: \(error)")
        }
    }

    // Cancels any active download and removes the pack from the device's storage.
    func clear() async {
        do {
            try await currentPack?.remove()
            self.currentPack = nil
            self.progress = 0
            self.state = .pending
        } catch {
            print("Clear failed: \(error)")
        }
    }

    // MARK: - MTOfflineDownloadDelegate

    nonisolated func offlinePack(_ pack: String, didChangeState state: MTOfflinePackState) {
        Task { @MainActor in self.state = state }
    }

    nonisolated func offlinePack(_ pack: String, didUpdateProgress progress: MTOfflinePackProgress) {
        Task { @MainActor in self.progress = Float(progress.percentage) }
    }

    nonisolated func offlinePack(_ pack: String, didFailResource error: MTOfflineError, context: MTOfflineContext) {
        // Handle individual resource failures if needed
    }

    nonisolated func offlinePack(_ pack: String, didSucceedResource context: MTOfflineContext) {
        // Handle individual resource successes if needed
    }
}

struct BasicOfflineDownloadExample: View {
    @StateObject private var manager = BasicOfflineDownloadManager()

    // Set up the map with an initial location and zoom level
    @State private var mapView = MTMapView(options: MTMapOptions(
        center: CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417),
        zoom: 12
    ))

    var body: some View {
        ZStack {
            // Display the map
            MTMapViewContainer(map: mapView) {}
                .referenceStyle(.streets)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                VStack(spacing: 12) {
                    Text("Basic Offline Download")
                        .font(.headline)

                    Text("State: \(manager.state.rawValue.capitalized)")
                        .font(.subheadline)

                    // Show progress bar only while actively downloading
                    if manager.state == .downloading {
                        ProgressView(value: manager.progress)
                            .progressViewStyle(.linear)
                            .padding(.horizontal)
                    }

                    HStack(spacing: 16) {
                        Button("Download View") {
                            Task {
                                let bounds = await mapView.getBounds()
                                await manager.downloadArea(bounds: bounds)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(manager.state == .downloading)

                        Button("Load Pack") {
                            Task {
                                if let pack = manager.currentPack {
                                    do {
                                        try await mapView.loadOfflinePack(pack)
                                    } catch {
                                        print("Failed to load pack: \(error)")
                                    }
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(manager.state != .completed || manager.currentPack == nil)

                        Button("Clear") {
                            Task {
                                // Restore the map to an online style and reset camera limits
                                await mapView.unloadOfflinePack()

                                await manager.clear()
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(manager.currentPack == nil && manager.state != .downloading)
                    }
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
            }
        }
    }
}
