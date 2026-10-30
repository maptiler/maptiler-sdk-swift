//
//  PackToolsView.swift
//  MapTilerMobileDemo
//
//  Hidden screen (long-press the Basic/Route switcher on the Offline tab) with the pack estimator used by sales
//  and the calibration tools that produce its size data.
//

import SwiftUI
import MapTilerSDK
import CoreLocation

struct PackToolsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var runner = CalibrationRunner()

    var body: some View {
        NavigationStack {
            TabView {
                PackEstimatorView(runner: runner)
                    .tabItem { Label("Estimator", systemImage: "ruler") }
                CalibrationView(runner: runner)
                    .tabItem { Label("Calibration", systemImage: "gauge.with.dots.needle.33percent") }
            }
            .navigationTitle("Pack tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Estimator

@MainActor
final class PackEstimatorModel: ObservableObject {
    enum Area: String, CaseIterable, Identifiable {
        case viewport = "Visible map"
        case geoJSON = "GeoJSON"
        var id: String { rawValue }
    }

    @Published var styleKey = "streets/default"
    @Published var minZoom = 0
    @Published var maxZoom = 14
    @Published var terrain = false
    @Published var paddingText = ""
    @Published var area = Area.viewport
    @Published var geoJSON = ""

    @Published var stats: MTPackStats?
    @Published var size: PackSizeEstimate?
    @Published var region: MTOfflineRegionDefinition?
    @Published var message: String?
    @Published var validation: PackMeasurement?

    let mapView = MTMapView(options: MTMapOptions())
    let sizeModel = PackToolsFiles.load(PackSizeModel.self, from: PackToolsFiles.sizeModel)

    func estimate(snapshot: PackSnapshot?) async {
        stats = nil
        size = nil
        validation = nil
        message = nil

        guard let snapshot, let metadata = snapshot.styles[styleKey], let style = PackStyle.with(id: styleKey) else {
            message = "No snapshot for \(styleKey). Build it in the Calibration tab."
            return
        }

        do {
            let region = MTOfflineRegionDefinition(
                geometry: try await geometry(),
                minZoom: minZoom,
                maxZoom: maxZoom,
                referenceStyle: style.style,
                styleVariant: style.variant,
                padding: Double(paddingText),
                isTerrainEnabled: terrain
            )
            // No network requests: the metadata comes from the snapshot.
            let stats = try MTOfflineEstimator().estimatePack(region: region, styleMetadata: metadata)
            self.region = region
            self.stats = stats
            if let sizeModel {
                size = try PackSizeEstimator.estimate(
                    region: region, metadata: metadata, stats: stats, model: sizeModel
                )
            } else {
                message = "No size model yet: sizes are not calibrated."
            }
        } catch {
            message = "Estimate failed: \(error)"
        }
    }

    private func geometry() async throws -> MTOfflineRegionGeometry {
        switch area {
        case .viewport:
            return .boundingBox(MTBoundingBox(bounds: await mapView.getBounds()))
        case .geoJSON:
            let coordinates = try MTGeoJSONParser.extractCoordinates(from: geoJSON)
            return geoJSON.contains("Polygon") ? .polygon(coordinates) : .route(coordinates)
        }
    }

    func validationRequest() -> ValidationRequest? {
        guard let region else { return nil }
        let bbox = region.bbox
        return ValidationRequest(
            id: "validation-\(Int(Date().timeIntervalSince1970))",
            styleKey: styleKey,
            bbox: [bbox.minLon, bbox.minLat, bbox.maxLon, bbox.maxLat],
            geometry: (try? JSONEncoder().encode(region.geometry)).flatMap { String(data: $0, encoding: .utf8) },
            minZoom: region.minZoom,
            maxZoom: region.maxZoom,
            padding: region.padding,
            terrain: region.isTerrainEnabled
        )
    }
}

struct PackEstimatorView: View {
    @ObservedObject var runner: CalibrationRunner
    @StateObject private var model = PackEstimatorModel()
    @State private var confirmValidation = false

    var body: some View {
        VStack(spacing: 0) {
            MTMapViewContainer(map: model.mapView) {}
                .referenceStyle(.streets)
                .frame(height: model.area == .viewport ? 260 : 0)

            Form {
                Section("Region") {
                    Picker("Style", selection: $model.styleKey) {
                        ForEach(PackStyle.all) { Text($0.id).tag($0.id) }
                    }
                    Picker("Area", selection: $model.area) {
                        ForEach(PackEstimatorModel.Area.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    if model.area == .geoJSON {
                        TextEditor(text: $model.geoJSON)
                            .font(.caption.monospaced())
                            .frame(minHeight: 100)
                    }
                    Stepper("Min zoom: \(model.minZoom)", value: $model.minZoom, in: 0...model.maxZoom)
                    Stepper("Max zoom: \(model.maxZoom)", value: $model.maxZoom, in: model.minZoom...22)
                    TextField("Padding in meters (default)", text: $model.paddingText)
                        .keyboardType(.decimalPad)
                    Toggle("3D terrain", isOn: $model.terrain)
                    Button("Estimate") {
                        Task { await model.estimate(snapshot: runner.snapshot) }
                    }
                }

                if let message = model.message {
                    Section { Text(message).foregroundStyle(.secondary) }
                }

                if let stats = model.stats {
                    PackStatsSection(stats: stats, size: model.size)

                    Section("Validate (billed)") {
                        Button("Download and measure (\(stats.resourceCount) requests)") {
                            confirmValidation = true
                        }
                        .disabled(runner.isRunning || stats.exceedsLimit)
                        if runner.isRunning {
                            ProgressView(value: runner.currentProgress)
                        }
                        if let validation = model.validation {
                            ValidationResultView(measurement: validation, estimate: model.size)
                        }
                    }
                }
            }
        }
        .alert("Download this pack?", isPresented: $confirmValidation) {
            Button("Download", role: .destructive) {
                guard let request = model.validationRequest() else { return }
                Task { model.validation = await runner.validate(request)?.measurement }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This makes \(model.stats?.resourceCount ?? 0) billed requests, then deletes the pack.")
        }
    }
}

struct PackStatsSection: View {
    let stats: MTPackStats
    let size: PackSizeEstimate?

    var body: some View {
        Section("Requests") {
            LabeledContent(
                "Resources",
                value: "\(stats.resourceCount.formatted()) / \(stats.resourceLimit.formatted())"
            )
                .foregroundStyle(stats.exceedsLimit ? .red : .primary)
            if let packs = stats.minimumPackCount {
                LabeledContent("Packs needed (at least)", value: "\(packs)")
            }
            LabeledContent("Glyphs", value: stats.glyphCount.formatted())
            LabeledContent("Sprites + style", value: (stats.spriteCount + stats.styleCount).formatted())
            ForEach(stats.sources, id: \.id) { source in
                LabeledContent("\(source.id) z\(source.minZoom)–\(source.maxZoom)", value: source.tileCount.formatted())
            }
        }

        if let size {
            Section("Size") {
                SizeRow(title: "Download", range: size.range(\.wire))
                SizeRow(title: "On device", range: size.range(\.allocated))
                if !size.uncalibratedSources.isEmpty {
                    Text("Rough: no calibration for \(size.uncalibratedSources.joined(separator: ", "))")
                        .font(.caption).foregroundStyle(.orange)
                }
                if !size.extrapolatedSources.isEmpty {
                    Text("Extrapolated beyond calibrated zoom: \(size.extrapolatedSources.joined(separator: ", "))")
                        .font(.caption).foregroundStyle(.orange)
                }
                if !size.unmeasuredOverhead.isEmpty {
                    Text("Rough: unmeasured \(size.unmeasuredOverhead.joined(separator: ", "))")
                        .font(.caption).foregroundStyle(.orange)
                }
            }
        }
    }
}

struct SizeRow: View {
    let title: String
    let range: SizeRange

    var body: some View {
        LabeledContent(title) {
            VStack(alignment: .trailing) {
                Text(format(range.value))
                Text("\(format(range.low)) – \(format(range.high))").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func format(_ bytes: Double) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }
}

struct ValidationResultView: View {
    let measurement: PackMeasurement
    let estimate: PackSizeEstimate?

    var body: some View {
        let actual = measurement.total
        LabeledContent("State", value: measurement.state)
        LabeledContent("Time", value: String(format: "%.0f s", measurement.seconds))
        comparison("Download", actual: actual.wire, estimated: estimate?.total.wire)
        comparison("On device", actual: actual.allocated, estimated: estimate?.total.allocated)
    }

    private func comparison(_ title: String, actual: Double, estimated: Double?) -> some View {
        let actualText = ByteCountFormatter.string(fromByteCount: Int64(actual), countStyle: .file)
        let error = estimated.map { actual > 0 ? String(format: " (%+.1f%%)", ($0 - actual) / actual * 100) : "" } ?? ""
        return LabeledContent("\(title) actual", value: actualText + error)
    }
}

// MARK: - Calibration

struct CalibrationView: View {
    @ObservedObject var runner: CalibrationRunner

    var body: some View {
        Form {
            Section("Style snapshot (billed)") {
                if let snapshot = runner.snapshot {
                    LabeledContent("Styles", value: "\(snapshot.styles.count)")
                    LabeledContent("Generated", value: snapshot.generatedAt.formatted())
                }
                Button(runner.snapshot == nil ? "Build snapshot (~3 requests per style)" : "Rebuild snapshot") {
                    Task { await runner.buildSnapshot() }
                }
                .disabled(runner.isRunning)
            }

            Section("Tile sizes") {
                Text("Tile sizes are calibrated on a Mac with maptiler-offline-estimator/calibration/calibrate.py, "
                    + "which reads the snapshot from this app and installs size-model.json back into it.")
                    .font(.caption)
                Text(PackToolsFiles.directory.path)
                    .font(.caption2.monospaced())
                    .textSelection(.enabled)
            }

            Section("Log") {
                ForEach(Array(runner.log.suffix(30).enumerated().reversed()), id: \.offset) { _, line in
                    Text(line).font(.caption2.monospaced())
                }
            }
        }
    }
}
