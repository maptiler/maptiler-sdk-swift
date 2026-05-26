//
//  OfflineBasic+SwiftUI.swift
//  MapTilerMobileDemo
//

import SwiftUI
import MapTilerSDK
import CoreLocation

@MainActor
final class OfflineViewModel: ObservableObject, MTOfflineDownloadDelegate {
    @Published var downloadProgress: Float = 0.0
    @Published var downloadState: String = "Idle"
    @Published var packSizeInfo: String = ""

    @Published var zurichPack: MTOfflinePack?
    @Published var brnoPack: MTOfflinePack?

    @Published var isZurichReady = false
    @Published var isBrnoReady = false

    @Published var showingRedownloadAlert = false
    @Published var activeCityName = ""

    var mapView = MTMapView(options: MTMapOptions())

    init() {
        Task {
            // Increase the global limit once at startup
            await MTConfig.shared.setOfflineMaxTileCount(25000)
            await refreshPacks()
        }
    }

    func refreshPacks() async {
        do {
            let packs = try await MTOfflinePack.packs()

            var zPack: MTOfflinePack?
            var bPack: MTOfflinePack?

            for pack in packs {
                if let name = await getPackName(pack) {
                    if name == "Zurich Offline" {
                        zPack = pack
                    } else if name == "Brno Offline" {
                        bPack = pack
                    }
                }
            }

            let zReady = await zPack?.state == .completed
            let bReady = await bPack?.state == .completed

            var totalSize: Int64 = 0
            if zReady { totalSize += await zPack?.metadata.size ?? 0 }
            if bReady { totalSize += await bPack?.metadata.size ?? 0 }

            self.zurichPack = zPack
            self.brnoPack = bPack
            self.isZurichReady = zReady
            self.isBrnoReady = bReady

            updateStatusLabel(zReady: zReady, bReady: bReady, totalSize: totalSize)
        } catch {
            print("Failed to load existing offline packs: \(error)")
        }
    }

    private func updateStatusLabel(zReady: Bool, bReady: Bool, totalSize: Int64) {
        if zReady && bReady {
            downloadState = "Zürich & Brno ready on disk"
        } else if zReady {
            downloadState = "Zürich ready on disk"
        } else if bReady {
            downloadState = "Brno ready on disk"
        } else {
            downloadState = "Idle"
        }

        if totalSize > 0 {
            packSizeInfo = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
        } else {
            packSizeInfo = ""
        }
    }

    private func getPackName(_ pack: MTOfflinePack) async -> String? {
        if let contextData = await pack.metadata.context,
            let contextDict = try? JSONDecoder().decode([String: String].self, from: contextData) {
            return contextDict["name"]
        }
        return nil
    }

    func downloadRegion() async {
        if isZurichReady {
            activeCityName = "Zürich"
            showingRedownloadAlert = true
            return
        }
        await performZurichDownload()
    }

    private func performZurichDownload() async {
        downloadState = "Estimating..."
        downloadProgress = 0.0
        packSizeInfo = ""

        // Define the region: Zurich, Switzerland
        let zurichBBox = MTBoundingBox(
            minLon: 8.448,
            minLat: 47.320,
            maxLon: 8.625,
            maxLat: 47.434
        )

        let region = MTOfflineRegionDefinition(
            bbox: zurichBBox,
            minZoom: 10,
            maxZoom: 14,
            referenceStyle: .outdoor
        )

        // Add a context dictionary so we can store custom metadata like the name
        let contextData = try? JSONEncoder().encode(["name": "Zurich Offline"])

        do {
            let pack = MTOfflinePack(region: region, context: contextData)
            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            self.zurichPack = pack
            self.isZurichReady = false
            downloadState = "Downloading Zürich..."

            // Mitigation for Error 1011: ensure session is ready
            try? await Task.sleep(nanoseconds: 500_000_000)
            try await pack.download()

        } catch {
            downloadState = "Error: \(error.localizedDescription)"
            print("Download failed: \(error)")
        }
    }

    func downloadBrnoBackground() async {
        if isBrnoReady {
            activeCityName = "Brno"
            showingRedownloadAlert = true
            return
        }
        await performBrnoDownload()
    }

    private func performBrnoDownload() async {
        downloadState = "Estimating..."
        downloadProgress = 0.0
        packSizeInfo = ""

        // Define the region: Brno, Czech Republic
        let brnoBBox = MTBoundingBox(
            minLon: 16.52,
            minLat: 49.13,
            maxLon: 16.70,
            maxLat: 49.25
        )

        let region = MTOfflineRegionDefinition(
            bbox: brnoBBox,
            minZoom: 10,
            maxZoom: 14,
            referenceStyle: .outdoor
        )

        let contextData = try? JSONEncoder().encode(["name": "Brno Offline"])

        do {
            let pack = MTOfflinePack(region: region, context: contextData)
            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            self.brnoPack = pack
            self.isBrnoReady = false
            downloadState = "Downloading Brno in Background..."

            // Mitigation for Error 1011: ensure session is ready
            try? await Task.sleep(nanoseconds: 500_000_000)
            // Important: useBackground flag set to true!
            try await pack.download(useBackground: true)

        } catch {
            downloadState = "Error: \(error.localizedDescription)"
            print("Download failed: \(error)")
        }
    }

    func confirmRedownload() async {
        if activeCityName == "Zürich" {
            if let pack = zurichPack { try? await pack.remove() }
            await performZurichDownload()
        } else if activeCityName == "Brno" {
            if let pack = brnoPack { try? await pack.remove() }
            await performBrnoDownload()
        }
    }

    func loadPack(_ pack: MTOfflinePack?) async {
        guard let pack = pack else { return }

        downloadState = "Loading offline style..."

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

            let size = await pack.metadata.size
            packSizeInfo = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)

            downloadState = "Loaded Offline Pack!"
        } catch {
            downloadState = "Failed to load pack: \(error.localizedDescription)"
        }
    }

    // MARK: - MTOfflineDownloadDelegate

    nonisolated func offlinePack(_ id: String, didUpdateProgress progress: MTOfflinePackProgress) {
        Task { @MainActor in
            self.downloadProgress = Float(progress.percentage)
            self.downloadState = "Downloading... (\(progress.downloadedResources)/\(progress.totalResources))"
        }
    }

    nonisolated func offlinePack(_ id: String, didChangeState state: MTOfflinePackState) {
        Task {
            if state == .completed {
                await refreshPacks()
            } else if state == .failed {
                await MainActor.run {
                    if !self.downloadState.contains("Error") {
                        self.downloadState = "Download Failed!"
                    }
                }
            }
        }
    }

    nonisolated func offlinePack(_ id: String, didReceiveError error: Error) {
        Task { @MainActor in
            self.downloadState = "Error: \(error.localizedDescription)"
        }
    }

    nonisolated func offlinePack(_ pack: String, didFailResource error: MTOfflineError, context: MTOfflineContext) {}
    nonisolated func offlinePack(_ pack: String, didSucceedResource context: MTOfflineContext) {}
}

struct DemoButtonStyle: ButtonStyle {
    var backgroundColor: Color = .white
    var foregroundColor: Color = .black // Default to black text when enabled
    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(isEnabled ? backgroundColor : backgroundColor.opacity(0.5))
            .foregroundColor(isEnabled ? foregroundColor : .gray)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct OfflineBasicView: View {
    @StateObject private var viewModel = OfflineViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            MTMapViewContainer(map: viewModel.mapView) {
                // Empty content
            }
            .referenceStyle(.outdoor)
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

                VStack(spacing: 4) {
                    Text("Status: \(viewModel.downloadState)")
                        .font(.subheadline)

                    if !viewModel.packSizeInfo.isEmpty {
                        Text("Size: \(viewModel.packSizeInfo)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        VStack {
                            Button("Download Zürich") {
                                Task { await viewModel.downloadRegion() }
                            }
                            .buttonStyle(DemoButtonStyle(backgroundColor: .blue, foregroundColor: .white))

                            Button("Load Zürich") {
                                Task { await viewModel.loadPack(viewModel.zurichPack) }
                            }
                            .buttonStyle(DemoButtonStyle())
                            .disabled(!viewModel.isZurichReady)
                        }

                        VStack {
                            Button("Download Brno") {
                                Task { await viewModel.downloadBrnoBackground() }
                            }
                            .buttonStyle(DemoButtonStyle(backgroundColor: .green, foregroundColor: .white))

                            Button("Load Brno") {
                                Task { await viewModel.loadPack(viewModel.brnoPack) }
                            }
                            .buttonStyle(DemoButtonStyle())
                            .disabled(!viewModel.isBrnoReady)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .cornerRadius(16)
            .padding()
        }
        .alert("Re-download \(viewModel.activeCityName)?", isPresented: $viewModel.showingRedownloadAlert) {
            Button("Re-download", role: .destructive) {
                Task { await viewModel.confirmRedownload() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This city is already ready on disk. Do you want to delete it and download again?")
        }
    }
}
