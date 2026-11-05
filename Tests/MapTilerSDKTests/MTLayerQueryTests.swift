//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import Foundation

@Suite
struct MTLayerQueryTests {
    private func layer(
        _ id: String,
        type: MTLayerType? = .fill,
        source: String? = "maptiler_planet",
        sourceLayer: String? = nil,
        isVisible: Bool = true
    ) -> MTStyleLayerInfo {
        MTStyleLayerInfo(
            id: id,
            type: type,
            rawType: type?.rawValue ?? "unknown",
            source: source,
            sourceLayer: sourceLayer,
            isVisible: isVisible,
            minZoom: nil,
            maxZoom: nil
        )
    }

    private func json(_ string: String) throws -> Any {
        try JSONSerialization.jsonObject(with: Data(string.utf8), options: .fragmentsAllowed)
    }

    // MARK: - Commands

    @Test func getStyleLayers_stringifiesLayersOrder() {
        let js = GetStyleLayers().toJS()
        #expect(js.hasPrefix("JSON.stringify("))
        #expect(js.contains("getLayersOrder()"))
        #expect(js.contains("sourceLayer: l.sourceLayer || null"))
    }

    @Test func getLayerProperty_escapesIdAndName() {
        let js = GetLayerProperty(layerId: "Water \"area\"", name: "fill-color", kind: .paint).toJS()
        #expect(js.contains("m.getLayer(\"Water \\\"area\\\"\")"))
        #expect(js.contains("m.getPaintProperty(\"Water \\\"area\\\"\", \"fill-color\")"))
    }

    @Test func setPropertyForLayers_batchesAllIds() {
        let js = SetPropertyForLayers(
            layerIds: ["Water", "River"],
            name: "visibility",
            value: .string("none"),
            kind: .layout
        ).toJS()
        #expect(js == "(function(ids, value) { var m = map;"
            + " ids.forEach(function(id) { if (m.getLayer(id)) { m.setLayoutProperty(id, \"visibility\", value); } });"
            + " })([\"Water\",\"River\"], \"none\");")
    }

    // MARK: - Decoding

    @Test func payload_decodesKnownAndUnknownTypes() {
        let layers = MTStyleLayerInfoPayload.decodeList(from: """
            [{"id":"Water","type":"fill","source":"maptiler_planet","sourceLayer":"water","visibility":"none"},
             {"id":"Sky","type":"sky","source":null,"sourceLayer":null,"visibility":"visible"}]
            """)

        #expect(layers.count == 2)
        #expect(layers[0].type == .fill)
        #expect(layers[0].sourceLayer == "water")
        #expect(layers[0].isVisible == false)
        #expect(layers[1].type == nil)
        #expect(layers[1].rawType == "sky")
        #expect(layers[1].isVisible)
    }

    @Test func payload_invalidJSONReturnsEmpty() {
        #expect(MTStyleLayerInfoPayload.decodeList(from: "not json").isEmpty)
    }

    // MARK: - Query

    @Test func emptyQuery_matchesEverything() {
        #expect(MTLayerQuery().matches(layer("anything")))
    }

    @Test func query_combinesCriteriaWithAnd() {
        let query = MTLayerQuery(types: [.line], categories: [.water])
        #expect(query.matches(layer("River", type: .line, sourceLayer: "waterway")))
        #expect(!query.matches(layer("Water", type: .fill, sourceLayer: "water")))
        #expect(!query.matches(layer("Road", type: .line, sourceLayer: "road")))
    }

    @Test func query_idContainsIsCaseInsensitive() {
        #expect(MTLayerQuery(idContains: "water").matches(layer("Water shadow")))
    }

    // MARK: - Categories

    @Test func categories_matchOpenMapTilesSourceLayers() {
        #expect(MTLayerCategory.water.matches(layer("Lake", sourceLayer: "water")))
        #expect(MTLayerCategory.nature.matches(layer("Grass", sourceLayer: "landcover")))
        #expect(MTLayerCategory.nature.matches(layer("Park", sourceLayer: "park")))
        #expect(!MTLayerCategory.nature.matches(layer("Residential", sourceLayer: "landuse")))
    }

    @Test func categories_matchPlanetV4SourceLayers() {
        #expect(MTLayerCategory.water.matches(layer("River labels", type: .symbol, sourceLayer: "water_label")))
        #expect(MTLayerCategory.nature.matches(layer("Forest", sourceLayer: "forest")))
        #expect(MTLayerCategory.roads.matches(layer("Road", type: .line, sourceLayer: "road")))
        #expect(MTLayerCategory.transit.matches(layer("Railway", type: .line, sourceLayer: "railway")))
        #expect(MTLayerCategory.places.matches(layer("City labels", type: .symbol, sourceLayer: "city_label")))
        #expect(MTLayerCategory.boundaries.matches(layer("Border", type: .line, sourceLayer: "country_border")))
        #expect(MTLayerCategory.terrain.matches(layer("Peak labels", type: .symbol, sourceLayer: "peak")))
    }

    @Test func poi_matchesSourceLayerPrefix() {
        #expect(MTLayerCategory.poi.matches(layer("Food", type: .symbol, sourceLayer: "poi_food")))
        #expect(!MTLayerCategory.poi.matches(layer("Point", type: .symbol, sourceLayer: "point")))
    }

    @Test func categories_doNotOverlap() {
        let sourceLayers = MTLayerCategory.allCases.flatMap { $0.sourceLayers }
        #expect(sourceLayers.count == Set(sourceLayers).count)
    }

    @Test func categories_matchKotlinSDKTable() {
        // Keep in sync with MTLayerCategory.kt and scripts/verify_layer_categories.py in the Kotlin SDK.
        let total = MTLayerCategory.allCases.reduce(0) { $0 + $1.sourceLayers.count }
        #expect(MTLayerCategory.allCases.count == 11)
        #expect(total == 87)
    }

    @Test func terrain_matchesHillshadeTypeAndSourceHint() {
        #expect(MTLayerCategory.terrain.matches(layer("Hillshade", type: .hillshade, source: "terrain-rgb")))
        #expect(MTLayerCategory.terrain.matches(layer("Shade", type: .raster, source: "hillshade")))
        #expect(!MTLayerCategory.terrain.matches(layer("Satellite", type: .raster, source: "satellite")))
    }

    // MARK: - Legend colors

    @Test func firstColor_plainColor() {
        #expect(MTLegendColorResolver.firstColor(in: "#aad3df") == "#aad3df")
    }

    @Test func firstColor_interpolateExpression() throws {
        let expr = try json(#"["interpolate",["linear"],["zoom"],4,"hsl(205, 56%, 73%)",10,"hsl(205, 56%, 80%)"]"#)
        #expect(MTLegendColorResolver.firstColor(in: expr) == "hsl(205, 56%, 73%)")
    }

    @Test func firstColor_legacyStops() throws {
        let stops = try json(##"{"base":1,"stops":[[0,"rgba(1,2,3,1)"],[10,"#fff"]]}"##)
        #expect(MTLegendColorResolver.firstColor(in: stops) == "rgba(1,2,3,1)")
    }

    @Test func firstColor_ignoresNonColorStrings() throws {
        let expr = try json(##"["match",["get","class"],"wood","#c0d8a0","#e0e8d0"]"##)
        #expect(MTLegendColorResolver.firstColor(in: expr) == "#c0d8a0")
        #expect(MTLegendColorResolver.firstColor(in: "linear") == nil)
        #expect(MTLegendColorResolver.firstColor(in: nil) == nil)
    }

    @Test func swatchSource_prefersFillOverSymbol() throws {
        let layers = [
            layer("Water name", type: .symbol, sourceLayer: "water_name"),
            layer("River", type: .line, sourceLayer: "waterway"),
            layer("Water", type: .fill, sourceLayer: "water")
        ]
        let swatch = try #require(MTLegendColorResolver.swatchSource(for: .water, in: layers))
        #expect(swatch.layer.id == "Water")
        #expect(swatch.property == "fill-color")
    }

    @Test func swatchSource_prefersRepresentativeSourceLayer() throws {
        let layers = [
            layer("Ice", sourceLayer: "ice"),
            layer("Grass", sourceLayer: "grass"),
            layer("Wood", sourceLayer: "wood")
        ]
        let swatch = try #require(MTLegendColorResolver.swatchSource(for: .nature, in: layers))
        #expect(swatch.layer.id == "Wood")
    }
}
