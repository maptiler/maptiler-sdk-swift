//
//  OfflineBasic+SwiftUI.swift
//  MapTilerMobileDemo
//

import SwiftUI
import MapTilerSDK
import CoreLocation

@MainActor
final class OfflineViewModel: ObservableObject, MTOfflineDownloadDelegate {
    enum Constants {
        enum DownloadStateLabel {
            static let idle = "Idle"
            static let unterageriAndBrnoReady = "Unterägeri & Brno ready on disk"
            static let unterageriReady = "Unterägeri ready on disk"
            static let brnoReady = "Brno ready on disk"
            static let estimating = "Estimating..."
            static let unterageriDownloading = "Downloading Unterägeri..."
            static let brnoDownloading = "Downloading Brno in Background..."
            static let loadingOfflineStyle = "Loading offline style..."
        }

        enum PackName {
            static let unterageri = "Unterägeri Offline"
            static let brno = "Brno Offline"
        }

        enum ActiveCityName {
            static let unterageri = "Unterägeri"
            static let brno = "Brno"
        }

        static let nameDictKey = "name"
        static let unterageriCoordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
    }

    @Published var downloadProgress: Float = 0.0
    @Published var downloadState: String = Constants.DownloadStateLabel.idle
    @Published var packSizeInfo: String = ""

    @Published var unterageriPack: MTOfflinePack?
    @Published var brnoPack: MTOfflinePack?

    @Published var isUnterageriReady = false
    @Published var isBrnoReady = false
    @Published var isMapReady = false

    @Published var showingRedownloadAlert = false
    @Published var activeCityName = ""

    var mapView = MTMapView(options: MTMapOptions())

    init() {
        Task {
            await refreshPacks()
        }
    }

    func refreshPacks() async {
        do {
            let packs = try await MTOfflinePack.packs()

            var uPack: MTOfflinePack?
            var bPack: MTOfflinePack?

            for pack in packs {
                if let name = await getPackName(pack) {
                    if name == Constants.PackName.unterageri {
                        uPack = pack
                    } else if name == Constants.PackName.brno {
                        bPack = pack
                    }
                }
            }

            let uReady = await uPack?.state == .completed
            let bReady = await bPack?.state == .completed

            var totalSize: Int64 = 0
            if uReady { totalSize += await uPack?.metadata.size ?? 0 }
            if bReady { totalSize += await bPack?.metadata.size ?? 0 }

            self.unterageriPack = uPack
            self.brnoPack = bPack
            self.isUnterageriReady = uReady
            self.isBrnoReady = bReady

            updateStatusLabel(uReady: uReady, bReady: bReady, totalSize: totalSize)
        } catch {
            print("Failed to load existing offline packs: \(error)")
        }
    }

    private func updateStatusLabel(uReady: Bool, bReady: Bool, totalSize: Int64) {
        if uReady && bReady {
            downloadState = Constants.DownloadStateLabel.unterageriAndBrnoReady
        } else if uReady {
            downloadState = Constants.DownloadStateLabel.unterageriReady
        } else if bReady {
            downloadState = Constants.DownloadStateLabel.brnoReady
        } else {
            downloadState = Constants.DownloadStateLabel.idle
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
            return contextDict[Constants.nameDictKey]
        }
        return nil
    }

    func downloadRegion() async {
        if isUnterageriReady {
            activeCityName = Constants.ActiveCityName.unterageri
            showingRedownloadAlert = true
            return
        }
        await performUnterageriDownload()
    }

    private func performUnterageriDownload() async {
        downloadState = Constants.DownloadStateLabel.estimating
        downloadProgress = 0.0
        packSizeInfo = ""

        // Define the region: Unterägeri, Switzerland
        let unterageriBBox = MTBoundingBox(
            minLon: 8.55,
            minLat: 47.10,
            maxLon: 8.62,
            maxLat: 47.16
        )

        let region = MTOfflineRegionDefinition(
            bbox: unterageriBBox,
            minZoom: 10,
            maxZoom: 14,
            referenceStyle: .outdoor
        )

        // Add a context dictionary so we can store custom metadata like the name
        let contextData = try? JSONEncoder().encode([Constants.nameDictKey: Constants.PackName.unterageri])

        do {
            let pack = MTOfflinePack(region: region, context: contextData)
            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            self.unterageriPack = pack
            self.isUnterageriReady = false
            downloadState = Constants.DownloadStateLabel.unterageriDownloading

            try await pack.download()

        } catch {
            downloadState = "Error: \(error.localizedDescription)"
            print("Download failed: \(error)")
        }
    }

    func downloadBrnoBackground() async {
        if isBrnoReady {
            activeCityName = Constants.ActiveCityName.brno
            showingRedownloadAlert = true
            return
        }
        await performBrnoDownload()
    }

    private func performBrnoDownload() async {
        downloadState = Constants.DownloadStateLabel.estimating
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

        let contextData = try? JSONEncoder().encode([Constants.nameDictKey: Constants.PackName.brno])

        do {
            let pack = MTOfflinePack(region: region, context: contextData)
            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            self.brnoPack = pack
            self.isBrnoReady = false
            downloadState = Constants.DownloadStateLabel.brnoDownloading

            // Important: useBackground flag set to true!
            try await pack.download(useBackground: true)

        } catch {
            downloadState = "Error: \(error.localizedDescription)"
            print("Download failed: \(error)")
        }
    }

    func confirmRedownload() async {
        if activeCityName == Constants.ActiveCityName.unterageri {
            if let pack = unterageriPack { try? await pack.remove() }
            await performUnterageriDownload()
        } else if activeCityName == Constants.ActiveCityName.brno {
            if let pack = brnoPack { try? await pack.remove() }
            await performBrnoDownload()
        }
    }

    func loadPack(_ pack: MTOfflinePack?) async {
        guard let pack = pack else { return }

        downloadState = Constants.DownloadStateLabel.loadingOfflineStyle

        do {
            // Load the downloaded pack into the map
            try await mapView.loadOfflinePack(pack)

            var center = CLLocationCoordinate2D(latitude: 47.13, longitude: 8.58)
            if let contextData = await pack.metadata.context,
                let contextDict = try? JSONDecoder().decode([String: String].self, from: contextData),
                contextDict[Constants.nameDictKey] == Constants.PackName.brno {
                center = CLLocationCoordinate2D(latitude: 49.1951, longitude: 16.6068)
            }

            // Jump to the downloaded region
            await mapView.jumpTo(
                center,
                options: MTCameraOptions(zoom: 12)
            )

            // Re-add the marker after style change (loading offline pack resets style)
            let marker = MTMarker(
                coordinates: Constants.unterageriCoordinates,
                icon: UIImage(named: "maptiler-marker")
            )
            await mapView.addMarker(marker)

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
    var foregroundColor: Color = .black
    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote)
            .bold()
            .lineLimit(1)
            .frame(maxWidth: .infinity, minHeight: 36)
            .padding(.horizontal, 4)
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
                MTMarker(
                    coordinates: OfflineViewModel.Constants.unterageriCoordinates,
                    icon: UIImage(named: "maptiler-marker")
                )
            }
            .referenceStyle(.outdoor)
            .didInitialize {
                viewModel.isMapReady = true
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
                            Button("Download Unterägeri") {
                                Task { await viewModel.downloadRegion() }
                            }
                            .buttonStyle(DemoButtonStyle(backgroundColor: .blue, foregroundColor: .white))
                            .disabled(!viewModel.isMapReady)

                            Button("Load Unterägeri") {
                                Task { await viewModel.loadPack(viewModel.unterageriPack) }
                            }
                            .buttonStyle(DemoButtonStyle())
                            .disabled(!viewModel.isUnterageriReady)
                        }

                        VStack {
                            Button("Download Brno") {
                                Task { await viewModel.downloadBrnoBackground() }
                            }
                            .buttonStyle(DemoButtonStyle(backgroundColor: .green, foregroundColor: .white))
                            .disabled(!viewModel.isMapReady)

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
