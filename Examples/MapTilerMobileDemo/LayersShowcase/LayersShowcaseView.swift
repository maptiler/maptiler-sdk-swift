//
//  LayersShowcaseView.swift
//  MapTilerMobileDemo
//

import SwiftUI
import CoreLocation
import MapTilerSDK

/// Full screen showcase of layer queries, visibility toggles, property updates and legends.
enum ShowcaseScene: CaseIterable, Identifiable {
    case legend
    case hideWater
    case natureOnly
    case noLabels
    case recolorRoads
    case queryLayers

    var id: Self { self }

    var chipTitle: String {
        switch self {
        case .legend: return "Legend"
        case .hideWater: return "Hide water"
        case .natureOnly: return "Nature & water"
        case .noLabels: return "No labels"
        case .recolorRoads: return "Recolor roads"
        case .queryLayers: return "Query layers"
        }
    }

    var icon: String {
        switch self {
        case .legend: return "list.bullet.rectangle"
        case .hideWater: return "drop"
        case .natureOnly: return "leaf"
        case .noLabels: return "textformat"
        case .recolorRoads: return "road.lanes"
        case .queryLayers: return "magnifyingglass"
        }
    }

    var title: String {
        switch self {
        case .legend: return "Build a legend"
        case .hideWater: return "Toggle a category"
        case .natureOnly: return "Combine categories"
        case .noLabels: return "Query by type"
        case .recolorRoads: return "Restyle layers"
        case .queryLayers: return "Inspect layers"
        }
    }

    var subtitle: String {
        switch self {
        case .legend: return "Colors, layer ids and visibility for every category in the style."
        case .hideWater: return "One call hides oceans, lakes, rivers and their labels."
        case .natureOnly: return "Hide everything except water, parks, forests and grass."
        case .noLabels: return "Hide every text and icon layer, regardless of the style."
        case .recolorRoads: return "Set a paint property on all road lines in one bridge call."
        case .queryLayers: return "List any layer of the style, including built-in MapTiler layers."
        }
    }

    /// The SDK call shown on screen, formatted to fit the card without wrapping.
    var code: String {
        switch self {
        case .legend:
            return "let legend = try await style.getLegend()"
        case .hideWater:
            return """
            try await style.setVisibility(
                false, for: .water
            )
            """
        case .natureOnly:
            return """
            let others = MTLayerQuery(categories:
                Set(MTLayerCategory.allCases)
                    .subtracting([.nature, .water]))
            try await style.setVisibility(
                false, matching: others
            )
            """
        case .noLabels:
            return """
            try await style.setVisibility(
                false,
                matching: MTLayerQuery(types: [.symbol])
            )
            """
        case .recolorRoads:
            return """
            try await style.setPaintProperty(
                "line-color",
                value: .string("#E4572E"),
                matching: MTLayerQuery(
                    types: [.line], categories: [.roads]
                )
            )
            """
        case .queryLayers:
            return """
            let layers = try await style
                .getStyleLayers(matching: .of(.water))
            """
        }
    }
}

@MainActor
final class LayersShowcaseViewModel: ObservableObject {
    enum Constants {
        static let zurich = CLLocationCoordinate2D(latitude: 47.350, longitude: 8.545)
        static let zoom = 12.4
        static let roadColor = "#E4572E"
    }

    let mapView = MTMapView(options: MTMapOptions(center: Constants.zurich, zoom: Constants.zoom))

    @Published private(set) var scene: ShowcaseScene = .legend
    @Published private(set) var result: String?
    @Published private(set) var legend: [MTLegendItem] = []
    @Published private(set) var queriedLayers: [MTStyleLayerInfo] = []
    @Published private(set) var isReady = false
    @Published private(set) var isBusy = false

    /// Layers this showcase hid, so a reset restores exactly them and never touches layers the style hides itself.
    private var hiddenLayerIds: Set<String> = []
    /// Original paint values of recolored layers, keyed by layer id.
    private var originalPaint: [String: (name: String, value: Any?)] = [:]

    private var style: MTStyle? { mapView.style }

    func mapDidBecomeReady() {
        guard !isReady else { return }
        isReady = true
        Task { await select(.legend) }
    }

    func select(_ newScene: ShowcaseScene) async {
        guard let style, !isBusy else { return }

        isBusy = true
        defer { isBusy = false }
        scene = newScene
        result = nil

        do {
            try await reset(style)
            result = try await apply(newScene, on: style)
            if newScene == .legend {
                legend = try await style.getLegend()
            }
        } catch {
            result = "Error: \(error)"
        }
    }

    func setCategory(_ category: MTLegendItem, visible: Bool) async {
        guard let style else { return }

        do {
            if visible {
                let ids = hiddenLayerIds.intersection(category.layerIds)
                try await style.setVisibility(true, matching: MTLayerQuery(ids: ids))
                hiddenLayerIds.subtract(ids)
            } else {
                try await hide(MTLayerQuery.of(category.category), on: style)
            }
            legend = try await style.getLegend()
            let hidden = legend.filter { !$0.isVisible }.count
            result = hidden == 0 ? "\(legend.count) categories" : "\(hidden) of \(legend.count) categories hidden"
        } catch {
            result = "Error: \(error)"
        }
    }

    // MARK: - Scenes

    private func apply(_ scene: ShowcaseScene, on style: MTStyle) async throws -> String {
        switch scene {
        case .legend:
            let legend = try await style.getLegend()
            return "\(legend.count) categories"
        case .hideWater:
            let count = try await hide(.of(.water), on: style)
            return "\(count) hidden"
        case .natureOnly:
            let others = Set(MTLayerCategory.allCases).subtracting([.nature, .water])
            let count = try await hide(MTLayerQuery(categories: others), on: style)
            return "\(count) hidden"
        case .noLabels:
            let count = try await hide(MTLayerQuery(types: [.symbol]), on: style)
            return "\(count) hidden"
        case .recolorRoads:
            let query = MTLayerQuery(types: [.line], categories: [.roads])
            for layer in try await style.getStyleLayers(matching: query) {
                let color = try await style.getPaintProperty(layerId: layer.id, name: "line-color")
                originalPaint[layer.id] = ("line-color", color)
            }
            let ids = try await style.setPaintProperty(
                "line-color",
                value: .string(Constants.roadColor),
                matching: query
            )
            return "\(ids.count) restyled"
        case .queryLayers:
            queriedLayers = try await style.getStyleLayers(matching: .of(.water))
            return "\(queriedLayers.count) matched"
        }
    }

    /// Hides the currently visible layers matching `query` and remembers them for the reset.
    @discardableResult
    private func hide(_ query: MTLayerQuery, on style: MTStyle) async throws -> Int {
        let ids = try await style.getStyleLayers(matching: query).filter(\.isVisible).map(\.id)
        try await style.setVisibility(false, matching: MTLayerQuery(ids: Set(ids)))
        hiddenLayerIds.formUnion(ids)
        return ids.count
    }

    private func reset(_ style: MTStyle) async throws {
        if !hiddenLayerIds.isEmpty {
            try await style.setVisibility(true, matching: MTLayerQuery(ids: hiddenLayerIds))
            hiddenLayerIds.removeAll()
        }

        for (layerId, paint) in originalPaint {
            await style.setPaintProperty(
                layerId: layerId,
                name: paint.name,
                value: .rawExpression(jsonLiteral(paint.value))
            )
        }
        originalPaint.removeAll()
    }

    private func jsonLiteral(_ value: Any?) -> String {
        guard
            let value,
            let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed),
            let json = String(bytes: data, encoding: .utf8)
        else {
            return "null"
        }
        return json
    }
}

struct LayersShowcaseView: View {
    @StateObject private var viewModel = LayersShowcaseViewModel()
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            MTMapViewContainer(map: viewModel.mapView) {}
                .referenceStyle(.streets)
                .didTriggerEvent { event, _ in
                    if event == .isReady {
                        viewModel.mapDidBecomeReady()
                    }
                }
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Spacer()
            }

            ShowcaseCard(viewModel: viewModel)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
            }
            .accessibilityLabel("Close")

            HStack(spacing: 8) {
                Image(systemName: "square.3.layers.3d")
                Text("Layers & Legends")
                    .font(.headline)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(.regularMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 6, y: 2)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
    }
}

private struct ShowcaseCard: View {
    @ObservedObject var viewModel: LayersShowcaseViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            chips

            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.scene.title)
                    .font(.title3.weight(.semibold))
                Spacer()
                if let result = viewModel.result {
                    Label(result, systemImage: "checkmark.circle.fill")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12), in: Capsule())
                }
            }

            Text(viewModel.scene.subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            CodeBlock(code: viewModel.scene.code)

            switch viewModel.scene {
            case .legend:
                LegendGrid(viewModel: viewModel)
            case .queryLayers:
                QueryList(layers: viewModel.queriedLayers)
            default:
                EmptyView()
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 16, y: 4)
        .overlay {
            if !viewModel.isReady {
                ProgressView("Loading map…")
            }
        }
    }

    private var chips: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ShowcaseScene.allCases) { scene in
                        let isSelected = scene == viewModel.scene
                        Button {
                            Task { await viewModel.select(scene) }
                        } label: {
                            Label(scene.chipTitle, systemImage: scene.icon)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .foregroundColor(isSelected ? .white : .primary)
                                .background(
                                    isSelected ? Color.accentColor : Color(.secondarySystemBackground),
                                    in: Capsule()
                                )
                        }
                        .id(scene)
                        .disabled(!viewModel.isReady)
                    }
                }
            }
            .onChange(of: viewModel.scene) { scene in
                withAnimation { proxy.scrollTo(scene, anchor: .center) }
            }
        }
    }
}

private struct CodeBlock: View {
    let code: String

    var body: some View {
        Text(code)
            .font(.system(size: 11.5, design: .monospaced))
            .foregroundColor(Color(red: 0.87, green: 0.92, blue: 1.0))
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(12)
            .background(Color(red: 0.11, green: 0.13, blue: 0.18), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct LegendGrid: View {
    @ObservedObject var viewModel: LayersShowcaseViewModel

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(viewModel.legend, id: \.category) { item in
                Button {
                    Task { await viewModel.setCategory(item, visible: !item.isVisible) }
                } label: {
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: UIColor(cssColor: item.color) ?? .systemGray4))
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primary.opacity(0.15)))
                            .frame(width: 18, height: 18)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(item.name)
                                .font(.footnote.weight(.medium))
                                .lineLimit(1)
                                .strikethrough(!item.isVisible)
                            Text("\(item.layerIds.count) layers")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: item.isVisible ? "eye" : "eye.slash")
                            .font(.caption)
                            .foregroundColor(item.isVisible ? .accentColor : .secondary)
                    }
                    .opacity(item.isVisible ? 1 : 0.5)
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

private struct QueryList: View {
    let layers: [MTStyleLayerInfo]
    private let visibleRows = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("id").frame(maxWidth: .infinity, alignment: .leading)
                Text("type").frame(width: 56, alignment: .leading)
                Text("source layer").frame(width: 104, alignment: .leading)
            }
            .font(.caption2.weight(.semibold))
            .foregroundColor(.secondary)

            ForEach(layers.prefix(visibleRows), id: \.id) { layer in
                HStack {
                    Text(layer.id).frame(maxWidth: .infinity, alignment: .leading)
                    Text(layer.rawType).frame(width: 56, alignment: .leading)
                    Text(layer.sourceLayer ?? "–").frame(width: 104, alignment: .leading)
                }
                .font(.system(size: 12, design: .monospaced))
                .lineLimit(1)
            }

            if layers.count > visibleRows {
                Text("+ \(layers.count - visibleRows) more")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
