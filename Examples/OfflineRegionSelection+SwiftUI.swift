import SwiftUI
import MapTilerSDK
import CoreLocation

/// This example demonstrates how to use the UI-to-Offline helpers to download an area
/// of the map defined by a visual selection box on the screen.
struct OfflineRegionSelectionExample: View {
    @StateObject private var downloadManager = OfflineDownloadManager()
    @State private var isMapReady = false

    // Create the map view with initial options
    @State private var mapView = MTMapView(options: MTMapOptions(
        center: CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417), // Zurich
        zoom: 12
    ))

    // Define the size of the selection box
    let selectionBoxSize: CGFloat = 250

    var body: some View {
        ZStack {
            MTMapViewContainer(map: mapView) {}
                .referenceStyle(.outdoor)
                .didInitialize {
                    isMapReady = true
                }
                .edgesIgnoringSafeArea(.all)

            // The visual selection box
            Rectangle()
                .strokeBorder(Color.blue, lineWidth: 3)
                .background(Color.blue.opacity(0.1))
                .frame(width: selectionBoxSize, height: selectionBoxSize)
                .allowsHitTesting(false) // Let touches pass through to the map

            VStack {
                Spacer()

                VStack(spacing: 12) {
                    Text("Pan and zoom to select an area")
                        .font(.headline)

                    Text("State: \(downloadManager.downloadState)")
                        .font(.subheadline)

                    if downloadManager.isDownloading {
                        ProgressView(value: downloadManager.downloadProgress)
                            .progressViewStyle(.linear)
                            .padding(.horizontal)
                    }

                    HStack(spacing: 20) {
                        Button("Download Selection") {
                            Task {
                                await downloadSelectedArea()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!isMapReady || downloadManager.isDownloading)

                        Button("Load Pack") {
                            Task {
                                await loadDownloadedPack()
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(
                            downloadManager.currentPack == nil ||
                            downloadManager.isDownloading ||
                            (downloadManager.packState != .completed)
                        )

                        Button("Clear") {
                            Task {
                                await downloadManager.clearOfflineData(mapView: mapView)
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(downloadManager.currentPack == nil && !downloadManager.isDownloading)
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

    private func downloadSelectedArea() async {
        downloadManager.prepareForDownload()

        // Calculate the frame of the selection box relative to the map view.
        let mapCenter = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.midY)
        let rect = CGRect(
            x: mapCenter.x - (selectionBoxSize / 2),
            y: mapCenter.y - (selectionBoxSize / 2),
            width: selectionBoxSize,
            height: selectionBoxSize
        )

        // Use the helper to create the offline region definition directly from the CGRect.
        let currentZoom = Int(mapView.cameraState.zoom)
        let region = await mapView.createOfflineRegion(
            covering: rect,
            minZoom: max(0, currentZoom - 2), // Download a few zooms out
            maxZoom: min(22, currentZoom + 2), // Download a few zooms in
            usePrecisePolygon: true
        )

        await downloadManager.startDownload(region: region)
    }

    private func loadDownloadedPack() async {
        guard let pack = downloadManager.currentPack else { return }

        do {
            try await mapView.loadOfflinePack(pack)
            downloadManager.downloadState = "Offline Pack Loaded"
        } catch {
            downloadManager.downloadState = "Failed to load: \(error.localizedDescription)"
        }
    }
}

/// Helper class to manage offline downloads and progress reporting.
@MainActor
class OfflineDownloadManager: NSObject, ObservableObject, MTOfflineDownloadDelegate {
    @Published var isDownloading = false
    @Published var downloadProgress: Float = 0.0
    @Published var downloadState = "Idle"
    @Published var packState: MTOfflinePackState = .pending
    @Published var currentPack: MTOfflinePack?

    func prepareForDownload() {
        isDownloading = true
        downloadState = "Estimating..."
        downloadProgress = 0.0
    }

    func startDownload(region: MTOfflineRegionDefinition) async {
        do {
            // Create and download the pack
            let pack = try await MTOfflinePack.createPack(region: region)

            // Set the delegate for progress reporting
            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            self.currentPack = pack
            self.downloadState = "Downloading..."

            try await pack.download()

        } catch {
            downloadState = "Error: \(error.localizedDescription)"
            isDownloading = false
        }
    }

    func clearOfflineData(mapView: MTMapView) async {
        guard let pack = currentPack else { return }

        do {
            try await pack.remove()
            self.currentPack = nil
            downloadState = "Pack Removed"
            downloadProgress = 0.0

            // Reset to online style
            await mapView.style?.setStyle(.outdoor)
        } catch {
            downloadState = "Failed to remove: \(error.localizedDescription)"
        }
    }

    // MARK: - MTOfflineDownloadDelegate

    func offlinePack(_ id: String, didUpdateProgress progress: MTOfflinePackProgress) {
        // Since we are @MainActor, we can update published properties directly
        self.downloadProgress = progress.percentage / 100.0
    }

    func offlinePack(_ id: String, didChangeState state: MTOfflinePackState) {
        self.packState = state

        switch state {
        case .downloading:
            downloadState = "Downloading..."
            isDownloading = true
        case .completed:
            downloadState = "Completed"
            isDownloading = false
        case .failed:
            downloadState = "Failed"
            isDownloading = false
        case .paused:
            downloadState = "Paused"
            isDownloading = false
        case .canceled:
            downloadState = "Canceled"
            isDownloading = false
        case .expired:
            downloadState = "Expired"
            isDownloading = false
        case .pending:
            downloadState = "Pending..."
            isDownloading = true
        @unknown default:
            break
        }
    }
}

#Preview {
    OfflineRegionSelectionExample()
}
