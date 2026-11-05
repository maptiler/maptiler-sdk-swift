//
//  LegendView.swift
//  MapTilerMobileDemo
//

import SwiftUI
import MapTilerSDK

/// Demonstrates `MTStyle.getLegend()`, category visibility toggles and query based property updates.
@MainActor
final class LegendViewModel: ObservableObject {
    @Published private(set) var items: [MTLegendItem] = []
    @Published private(set) var labelsVisible = true
    @Published private(set) var buildingsDimmed = false
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private weak var mapView: MTMapView?

    private let labelsQuery = MTLayerQuery(types: [.symbol])
    private let legendQuery = MTLayerQuery(categories: Set(MTLayerCategory.allCases))

    init(mapView: MTMapView) {
        self.mapView = mapView
    }

    func load() async {
        guard let style = mapView?.style else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            items = try await style.getLegend()
            labelsVisible = try await style.getStyleLayers(matching: labelsQuery).contains { $0.isVisible }
        } catch {
            errorMessage = "\(error)"
        }
    }

    func setVisible(_ visible: Bool, for item: MTLegendItem) async {
        await run { style in try await style.setVisibility(visible, for: item.category) }
    }

    func setAllVisible(_ visible: Bool) async {
        await run { style in try await style.setVisibility(visible, matching: self.legendQuery) }
    }

    func setLabelsVisible(_ visible: Bool) async {
        await run { style in try await style.setVisibility(visible, matching: self.labelsQuery) }
    }

    func setBuildingsDimmed(_ dimmed: Bool) async {
        buildingsDimmed = dimmed
        await run { style in
            let opacity = MTPropertyValue.number(dimmed ? 0.25 : 1.0)
            try await style.setPaintProperty("fill-opacity", value: opacity, matching: MTLayerQuery(
                types: [.fill],
                categories: [.buildings]
            ))
            try await style.setPaintProperty("fill-extrusion-opacity", value: opacity, matching: MTLayerQuery(
                types: [.fillExtrusion],
                categories: [.buildings]
            ))
        }
    }

    /// Runs a style mutation, then reloads the legend
    private func run(_ action: (MTStyle) async throws -> Void) async {
        guard let style = mapView?.style else { return }

        do {
            try await action(style)
        } catch {
            errorMessage = "\(error)"
        }
        await load()
    }
}

struct LegendView: View {
    @ObservedObject var viewModel: LegendViewModel

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(viewModel.items, id: \.category) { item in
                        LegendRow(item: item) { visible in
                            Task { await viewModel.setVisible(visible, for: item) }
                        }
                    }
                } header: {
                    Text("Legend")
                } footer: {
                    Text("Categories are matched by vector tile source layer, so they work across MapTiler styles.")
                }

                Section("Layer queries") {
                    Toggle("All labels", isOn: Binding(
                        get: { viewModel.labelsVisible },
                        set: { visible in Task { await viewModel.setLabelsVisible(visible) } }
                    ))
                    Toggle("Dim buildings", isOn: Binding(
                        get: { viewModel.buildingsDimmed },
                        set: { dimmed in Task { await viewModel.setBuildingsDimmed(dimmed) } }
                    ))
                }
            }
            .overlay {
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView()
                }
            }
            .navigationTitle("Layers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Show all") { Task { await viewModel.setAllVisible(true) } }
                        Button("Hide all") { Task { await viewModel.setAllVisible(false) } }
                        Button("Reload") { Task { await viewModel.load() } }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .task { await viewModel.load() }
    }
}

private struct LegendRow: View {
    let item: MTLegendItem
    let onToggle: (Bool) -> Void

    var body: some View {
        Toggle(isOn: Binding(get: { item.isVisible }, set: onToggle)) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(uiColor: UIColor(cssColor: item.color) ?? .systemGray4))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primary.opacity(0.15)))
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                    Text("\(item.layerIds.count) layers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

extension UIColor {
    /// Parses the CSS colors used in MapTiler styles: `#rgb`, `#rrggbb`, `#rrggbbaa`, `rgb()`, `rgba()`,
    /// `hsl()` and `hsla()`.
    convenience init?(cssColor: String?) {
        guard let css = cssColor?.trimmingCharacters(in: .whitespaces).lowercased() else { return nil }

        if css.hasPrefix("#") {
            var hex = String(css.dropFirst())
            if hex.count == 3 { hex = hex.map { "\($0)\($0)" }.joined() }
            guard hex.count == 6 || hex.count == 8, let value = UInt64(hex, radix: 16) else { return nil }

            let hasAlpha = hex.count == 8
            let shift: UInt64 = hasAlpha ? 8 : 0
            self.init(
                red: CGFloat((value >> (16 + shift)) & 0xFF) / 255,
                green: CGFloat((value >> (8 + shift)) & 0xFF) / 255,
                blue: CGFloat((value >> shift) & 0xFF) / 255,
                alpha: hasAlpha ? CGFloat(value & 0xFF) / 255 : 1
            )
            return
        }

        guard let open = css.firstIndex(of: "("), let close = css.lastIndex(of: ")") else { return nil }
        let function = css[..<open]
        let parts = css[css.index(after: open)..<close]
            .split { $0 == "," || $0 == " " || $0 == "/" }
            .map { Double($0.replacingOccurrences(of: "%", with: "")) ?? 0 }
        guard parts.count >= 3 else { return nil }
        let alpha = parts.count > 3 ? parts[3] : 1

        switch function {
        case "rgb", "rgba":
            self.init(red: parts[0] / 255, green: parts[1] / 255, blue: parts[2] / 255, alpha: alpha)
        case "hsl", "hsla":
            // HSL -> HSB conversion.
            let lightness = parts[2] / 100
            let saturation = parts[1] / 100
            let brightness = lightness + saturation * min(lightness, 1 - lightness)
            let hsbSaturation = brightness == 0 ? 0 : 2 * (1 - lightness / brightness)
            self.init(hue: parts[0] / 360, saturation: hsbSaturation, brightness: brightness, alpha: alpha)
        default:
            return nil
        }
    }
}
