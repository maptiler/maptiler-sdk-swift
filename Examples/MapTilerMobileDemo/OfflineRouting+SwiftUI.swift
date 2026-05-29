//
//  OfflineRouting+SwiftUI.swift
//  MapTilerMobileDemo
//

import SwiftUI
import MapTilerSDK
import CoreLocation

@MainActor
final class OfflineRoutingViewModel: ObservableObject, MTOfflineDownloadDelegate {
    enum Constants {
        enum DownloadStateLabel {
            static let idle = "Idle"
            static let routeReady = "Route ready on disk"
            static let routeDownloading = "Downloading Route..."
            static let loadingOfflineStyle = "Loading offline style..."
        }

        static let nameDictKey = "name"
        static let packName = "Route Offline"
    }

    @Published var downloadProgress: Float = 0.0
    @Published var downloadState: String = Constants.DownloadStateLabel.idle
    @Published var packSizeInfo: String = ""
    @Published var routePack: MTOfflinePack?
    @Published var isRouteReady = false
    @Published var isMapReady = false
    @Published var routeInjected = true // Starts true to not inject on launch

    var mapView = MTMapView(options: MTMapOptions())

    init() {
        Task {
            await refreshPacks()
        }
    }

    func refreshPacks() async {
        do {
            let packs = try await MTOfflinePack.packs()
            for pack in packs {
                if let contextData = await pack.metadata.context,
                    let contextDict = try? JSONDecoder().decode([String: String].self, from: contextData),
                    contextDict[Constants.nameDictKey] == Constants.packName {
                    self.routePack = pack
                    self.isRouteReady = await pack.state == .completed

                    if self.isRouteReady {
                        let size = await pack.metadata.size
                        self.packSizeInfo = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
                        self.downloadState = Constants.DownloadStateLabel.routeReady
                    }
                    return
                }
            }
        } catch {
            print("Failed to load packs: \(error)")
        }
    }

    func downloadRoute() async {
        if isRouteReady {
            if let pack = routePack { try? await pack.remove() }
            isRouteReady = false
        }

        downloadState = "Parsing GeoJSON..."
        downloadProgress = 0.0

        // A simple sample GeoJSON of a LineString
        let lineGeoJSON = """
        {
            "type": "Feature",
            "properties": {},
            "geometry": {
                "type": "LineString",
                "coordinates": [
                    [14.41790, 50.08182],
                    [14.42398, 50.08149],
                    [14.42533, 50.07923],
                    [14.43129, 50.08051],
                    [14.43328, 50.07835]
                ]
            }
        }
        """

        do {
            // Extract coordinates directly using MTGeoJSONParser
            let routeCoordinates = try MTGeoJSONParser.extractCoordinates(from: lineGeoJSON)

            // Provide coordinates to flexible .route geometry
            let region = MTOfflineRegionDefinition(
                geometry: .route(routeCoordinates),
                minZoom: 9,
                maxZoom: 14,
                referenceStyle: .outdoor
            )

            let contextData = try? JSONEncoder().encode([Constants.nameDictKey: Constants.packName])
            let pack = MTOfflinePack(region: region, context: contextData)

            await pack.setDelegate(self)
            await pack.setProgressReportingEnabled(true)

            self.routePack = pack
            downloadState = Constants.DownloadStateLabel.routeDownloading

            try await pack.download()

        } catch {
            downloadState = "Error: \(error.localizedDescription)"
        }
    }

    func loadPack() async {
        guard let pack = routePack else { return }
        routeInjected = false
        downloadState = "Loading offline style..."

        do {
            try await mapView.loadOfflinePack(pack)
            await mapView.jumpTo(
                CLLocationCoordinate2D(latitude: 50.08051, longitude: 14.42533),
                options: MTCameraOptions(zoom: 13)
            )
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
            }
        }
    }

    nonisolated func offlinePack(_ id: String, didReceiveError error: Error) {
        Task { @MainActor in self.downloadState = "Error: \(error.localizedDescription)" }
    }
    nonisolated func offlinePack(_ pack: String, didFailResource error: MTOfflineError, context: MTOfflineContext) {}
    nonisolated func offlinePack(_ pack: String, didSucceedResource context: MTOfflineContext) {}
}

struct OfflineRoutingView: View {
    @StateObject private var viewModel = OfflineRoutingViewModel()

    // The GeoJSON string representing our route
    private let lineGeoJSON = """
    {
        "type": "Feature",
        "properties": {},
        "geometry": {
            "type": "LineString",
            "coordinates": [
                [14.41790, 50.08182],
                [14.42398, 50.08149],
                [14.42533, 50.07923],
                [14.43129, 50.08051],
                [14.43328, 50.07835]
            ]
        }
    }
    """

    var body: some View {
        ZStack(alignment: .bottom) {
            MTMapViewContainer(map: viewModel.mapView) {}
            .referenceStyle(.outdoor)
            .didInitialize {
                viewModel.isMapReady = true
            }
            .didTriggerEvent { event, _ in
                // .isReady fires on initial map load.
                // .isIdle fires once all style parsing, tile downloading, and camera panning is 100% complete
                if event == .isIdle && !viewModel.routeInjected {
                    viewModel.routeInjected = true
                    Task {
                        let source = MTGeoJSONSource(identifier: "route-source", jsonString: lineGeoJSON)
                        let layer = MTLineLayer(identifier: "route-layer", sourceIdentifier: "route-source")
                        layer.color = .systemBlue
                        layer.width = 5

                        try? await viewModel.mapView.style?.addSource(source)
                        try? await viewModel.mapView.style?.addLayer(layer)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                Text("Offline Route Download")
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

                HStack(spacing: 16) {
                    Button("Download Route") {
                        Task { await viewModel.downloadRoute() }
                    }
                    .buttonStyle(DemoButtonStyle(backgroundColor: .blue, foregroundColor: .white))
                    .disabled(!viewModel.isMapReady)

                    Button("Load Route") {
                        Task { await viewModel.loadPack() }
                    }
                    .buttonStyle(DemoButtonStyle())
                    .disabled(!viewModel.isRouteReady)
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .cornerRadius(16)
            .padding()
        }
    }
}
