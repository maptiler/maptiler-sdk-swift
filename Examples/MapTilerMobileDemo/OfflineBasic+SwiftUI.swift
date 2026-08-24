//
//  OfflineBasic+SwiftUI.swif
//  MapTilerMobileDemo
//

import SwiftUI
import MapTilerSDK
import CoreLocation

private enum OfflineConstants {
    enum DownloadStateLabel {
        static let idle = "Idle"
        static let allReady = "Regions ready on disk"
        static let unterageriReady = "Unterägeri ready on disk"
        static let brnoReady = "Brno ready on disk"
        static let yellowstoneReady = "Yellowstone ready on disk"
        static let estimating = "Estimating..."
        static let unterageriDownloading = "Downloading Unterägeri..."
        static let brnoDownloading = "Downloading Brno in Background..."
        static let yellowstoneDownloading = "Downloading Yellowstone..."
        static let loadingOfflineStyle = "Loading offline style..."
    }

    enum PackName {
        static let unterageri = "Unterägeri Offline"
        static let brno = "Brno Offline"
        static let yellowstone = "Yellowstone Offline"
    }

    enum ActiveCityName {
        static let unterageri = "Unterägeri"
        static let brno = "Brno"
        static let yellowstone = "Yellowstone"
    }

    static let nameDictKey = "name"
    static let unterageriCoordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
    static let yellowstoneCoordinates = CLLocationCoordinate2D(latitude: 44.4280, longitude: -110.5885)
}

@MainActor
final class OfflineViewModel: ObservableObject {
    private var currentStyle: MTMapReferenceStyle = .streets

    @Published var downloadProgress: Float = 0.0
    @Published var downloadState: String = OfflineConstants.DownloadStateLabel.idle
    @Published var packInfo: String = ""

    @Published var unterageriPack: MTOfflinePack?
    @Published var brnoPack: MTOfflinePack?
    @Published var yellowstonePack: MTOfflinePack?

    @Published var isUnterageriReady = false
    @Published var isBrnoReady = false
    @Published var isYellowstoneReady = false
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
            var yPack: MTOfflinePack?

            for pack in packs {
                if let name = await getPackName(pack) {
                    switch name {
                    case OfflineConstants.PackName.unterageri: uPack = pack
                    case OfflineConstants.PackName.brno: bPack = pack
                    case OfflineConstants.PackName.yellowstone: yPack = pack
                    default: break
                    }
                }
            }

            let uReady = await uPack?.state == .completed
            let bReady = await bPack?.state == .completed
            let yReady = await yPack?.state == .completed

            var totalSize: Int64 = 0
            if uReady { totalSize += await uPack?.metadata.size ?? 0 }
            if bReady { totalSize += await bPack?.metadata.size ?? 0 }
            if yReady { totalSize += await yPack?.metadata.size ?? 0 }

            self.unterageriPack = uPack
            self.brnoPack = bPack
            self.yellowstonePack = yPack
            self.isUnterageriReady = uReady
            self.isBrnoReady = bReady
            self.isYellowstoneReady = yReady

            // Determine which pack to show details for (prefer the active one, or any ready one)
            var packToShow: MTOfflinePack?

            let packMatchesActiveName = { (pack: MTOfflinePack?) async -> Bool in
                guard let pack = pack, let name = await self.getPackName(pack) else { return false }
                return name == self.activeCityName
            }

            if await packMatchesActiveName(yPack) {
                packToShow = yPack
            } else if await packMatchesActiveName(bPack) {
                packToShow = bPack
            } else if await packMatchesActiveName(uPack) {
                packToShow = uPack
            } else {
                packToShow = yPack ?? bPack ?? uPack
            }

            await updateStatusLabel(
                uReady: uReady, bReady: bReady, yReady: yReady,
                totalSize: totalSize, packToShow: packToShow
            )
        } catch {
            print("Failed to load existing offline packs: \(error)")
        }
    }

    private func generatePackInfo(for pack: MTOfflinePack, totalSize: Int64) async -> String {
        let metadata = await pack.metadata
        let progress = await pack.progress
        let sizeStr = ByteCountFormatter.string(fromByteCount: metadata.size, countStyle: .file)
        let totalSizeStr = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
        let dateStr = DateFormatter.localizedString(from: metadata.createdAt, dateStyle: .short, timeStyle: .short)
        let expStr = DateFormatter.localizedString(from: metadata.expiresAt, dateStyle: .short, timeStyle: .short)

        let areaSqKm = AreaCalculator.areaInSquareKilometers(for: metadata.region.geometry.bbox)
        let areaStr = String(format: "%.1f sq km", areaSqKm)

        return """
        Pack Size: \(sizeStr) (Total All Packs: \(totalSizeStr))
        Area: ~\(areaStr)
        Resources: \(progress.downloadedResources)/\(progress.totalResources)
        Created: \(dateStr)
        Expires: \(expStr)
        Pixel Ratio: \(metadata.region.pixelRatio)x
        """
    }

    private func updateStatusLabel(
        uReady: Bool, bReady: Bool, yReady: Bool,
        totalSize: Int64, packToShow: MTOfflinePack?
    ) async {
        if uReady && bReady && yReady {
            downloadState = OfflineConstants.DownloadStateLabel.allReady
        } else if uReady {
            downloadState = OfflineConstants.DownloadStateLabel.unterageriReady
        } else if bReady {
            downloadState = OfflineConstants.DownloadStateLabel.brnoReady
        } else if yReady {
            downloadState = OfflineConstants.DownloadStateLabel.yellowstoneReady
        } else {
            downloadState = OfflineConstants.DownloadStateLabel.idle
        }

        if let pack = packToShow {
            packInfo = await generatePackInfo(for: pack, totalSize: totalSize)
        } else if totalSize > 0 {
            packInfo = "Total size: \(ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file))"
        } else {
            packInfo = ""
        }
    }

    private func getPackName(_ pack: MTOfflinePack) async -> String? {
        if let contextData = await pack.metadata.context,
            let contextDict = try? JSONDecoder().decode([String: String].self, from: contextData) {
            return contextDict[OfflineConstants.nameDictKey]
        }
        return nil
    }

    func loadPack(_ pack: MTOfflinePack?) async {
        guard let pack = pack else { return }

        downloadState = OfflineConstants.DownloadStateLabel.loadingOfflineStyle

        do {
            // Load the downloaded pack into the map
            try await mapView.loadOfflinePack(pack)

            var center = OfflineConstants.unterageriCoordinates
            let name = await getPackName(pack)
            if name == OfflineConstants.PackName.brno {
                center = CLLocationCoordinate2D(latitude: 49.1951, longitude: 16.6068)
            } else if name == OfflineConstants.PackName.yellowstone {
                center = OfflineConstants.yellowstoneCoordinates
            }

            // Jump to the downloaded region
            await mapView.jumpTo(
                center,
                options: MTCameraOptions(zoom: 12)
            )

            // Re-add the marker after style change (loading offline pack resets style)
            let marker = MTMarker(
                coordinates: center,
                icon: UIImage(named: "maptiler-marker")
            )
            await mapView.addMarker(marker)

            // We calculate total size across all ready packs to pass to generatePackInfo
            var totalSize: Int64 = 0
            if isUnterageriReady { totalSize += await unterageriPack?.metadata.size ?? 0 }
            if isBrnoReady { totalSize += await brnoPack?.metadata.size ?? 0 }
            if isYellowstoneReady { totalSize += await yellowstonePack?.metadata.size ?? 0 }

            packInfo = await generatePackInfo(for: pack, totalSize: totalSize)

            downloadState = "Loaded \(name ?? "Pack")!"        } catch {
            downloadState = "Failed to load pack: \(error.localizedDescription)"
        }
    }
}

// MARK: - Download Methods
extension OfflineViewModel {
    func downloadUnterageri() async {
        if isUnterageriReady {
            activeCityName = OfflineConstants.ActiveCityName.unterageri
            showingRedownloadAlert = true
            return
        }
        await performUnterageriDownload()
    }

    private func performUnterageriDownload() async {
        downloadState = OfflineConstants.DownloadStateLabel.estimating
        downloadProgress = 0.0
        packInfo = ""

        let region = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 8.55, minLat: 47.10, maxLon: 8.62, maxLat: 47.16),
            minZoom: 10, maxZoom: 14, referenceStyle: currentStyle
        )

        let contextData = try? JSONEncoder().encode([
            OfflineConstants.nameDictKey: OfflineConstants.PackName.unterageri
        ])

        do {
            let pack = MTOfflinePack(region: region, context: contextData)
            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            self.unterageriPack = pack
            self.isUnterageriReady = false
            downloadState = OfflineConstants.DownloadStateLabel.unterageriDownloading

            try await pack.download()
        } catch {
            downloadState = "Error: \(error.localizedDescription)"
        }
    }

    func downloadBrnoBackground() async {
        if isBrnoReady {
            activeCityName = OfflineConstants.ActiveCityName.brno
            showingRedownloadAlert = true
            return
        }
        await performBrnoDownload()
    }

    private func performBrnoDownload() async {
        downloadState = OfflineConstants.DownloadStateLabel.estimating
        downloadProgress = 0.0
        packInfo = ""

        let region = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 16.52, minLat: 49.13, maxLon: 16.70, maxLat: 49.25),
            minZoom: 12, maxZoom: 16, referenceStyle: currentStyle
        )

        let contextData = try? JSONEncoder().encode([OfflineConstants.nameDictKey: OfflineConstants.PackName.brno])

        do {
            let pack = MTOfflinePack(region: region, context: contextData)
            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            self.brnoPack = pack
            self.isBrnoReady = false
            downloadState = OfflineConstants.DownloadStateLabel.brnoDownloading

            try await pack.download(useBackground: true)
        } catch {
            downloadState = "Error: \(error.localizedDescription)"
        }
    }

    func downloadYellowstone() async {
        if isYellowstoneReady {
            activeCityName = OfflineConstants.ActiveCityName.yellowstone
            showingRedownloadAlert = true
            return
        }
        await performYellowstoneDownload()
    }

    private func performYellowstoneDownload() async {
        downloadState = OfflineConstants.DownloadStateLabel.estimating
        downloadProgress = 0.0
        packInfo = ""

        let region = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: -111.15, minLat: 44.12, maxLon: -109.81, maxLat: 45.10),
            minZoom: 7, maxZoom: 13, referenceStyle: currentStyle
        )

        let contextData = try? JSONEncoder().encode([
            OfflineConstants.nameDictKey: OfflineConstants.PackName.yellowstone
        ])

        do {
            let pack = MTOfflinePack(region: region, context: contextData)
            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            self.yellowstonePack = pack
            self.isYellowstoneReady = false
            downloadState = OfflineConstants.DownloadStateLabel.yellowstoneDownloading

            try await pack.download()
        } catch {
            downloadState = "Error: \(error.localizedDescription)"
        }
    }

    func confirmRedownload() async {
        if activeCityName == OfflineConstants.ActiveCityName.unterageri {
            if let pack = unterageriPack { try? await pack.remove() }
            await performUnterageriDownload()
        } else if activeCityName == OfflineConstants.ActiveCityName.brno {
            if let pack = brnoPack { try? await pack.remove() }
            await performBrnoDownload()
        } else if activeCityName == OfflineConstants.ActiveCityName.yellowstone {
            if let pack = yellowstonePack { try? await pack.remove() }
            await performYellowstoneDownload()
        }
    }
}

// MARK: - MTOfflineDownloadDelegate
extension OfflineViewModel: MTOfflineDownloadDelegate {
    nonisolated func offlinePack(_ id: String, didUpdateProgress progress: MTOfflinePackProgress) {
        Task { @MainActor in
            let activePack = [self.unterageriPack, self.brnoPack, self.yellowstonePack]
                .compactMap { $0 }
                .first { $0.id == id }

            if await activePack?.state == .downloading {
                self.downloadProgress = Float(progress.percentage)
                self.downloadState = "Downloading... (\(progress.downloadedResources)/\(progress.totalResources))"
            }
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
                    coordinates: OfflineConstants.unterageriCoordinates,
                    icon: UIImage(named: "maptiler-marker")
                )
            }
            .referenceStyle(.streets)
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

                    if !viewModel.packInfo.isEmpty {
                        Text(viewModel.packInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        VStack {
                            Button("Download Unterägeri") {
                                Task { await viewModel.downloadUnterageri() }
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

                        VStack {
                            Button("Download Yellowstone") {
                                Task { await viewModel.downloadYellowstone() }
                            }
                            .buttonStyle(DemoButtonStyle(backgroundColor: .orange, foregroundColor: .white))
                            .disabled(!viewModel.isMapReady)

                            Button("Load Yellowstone") {
                                Task { await viewModel.loadPack(viewModel.yellowstonePack) }
                            }
                            .buttonStyle(DemoButtonStyle())
                            .disabled(!viewModel.isYellowstoneReady)
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
