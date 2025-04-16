//
//  MTBenchmark.swift
//  MapTilerSDK
//

import CoreLocation
import os
import Foundation
import UIKit

// Overview of performance.
// Detailed benchmarking is performed by Benchmarking package.
// swiftlint:disable all

/// Basic benchmarking class.
public final class MTBenchmark: MTMapViewDelegate {
    let zoom = 6.0
    let centerCoordinate = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
    var apiKey = "YOUR_API_KEY_HERE"

    // https://api.maptiler.com/tiles/uk-openzoomstack/{z}/{x}/{y}.pbf?key=\(apiKey)
    let openStackTiles: [(String, UIColor)] = [
        (
            "sea",
            UIColor.random()
        ),
        (
            "names",
            UIColor.random()
        ),
        (
            "rail",
            UIColor.random()
        ),
        (
            "waterlines",
            UIColor.random()
        ),
        (
            "etl",
            UIColor.random()
        ),
        (
            "foreshore",
            UIColor.random()
        ),
        (
            "sites",
            UIColor.random()
        ),
        (
            "railwaystations",
            UIColor.random()
        ),
        (
            "roads",
            UIColor.random()
        ),
        (
            "greenspaces",
            UIColor.random()
        ),
        (
            "contours",
            UIColor.random()
        ),
        (
            "buildings",
            UIColor.random()
        ),
        (
            "boundaries",
            UIColor.random()
        ),
        (
            "airports",
            UIColor.random()
        ),
        (
            "woodland",
            UIColor.random()
        ),
        (
            "national_parks",
            UIColor.random()
        ),
        (
            "urban_areas",
            UIColor.random()
        ),
        (
            "surfacewater",
            UIColor.random()
        )
    ]

    // https://api.maptiler.com/tiles/v3-openmaptiles/{z}/{x}/{y}.pbf?key=\(apiKey)
    let openMapTiles: [(String, UIColor)] = [
        (
            "water",
            UIColor.random()
        ),
        (
            "waterway",
            UIColor.random()
        ),
        (
            "landcover",
            UIColor.random()
        ),
        (
            "landuse",
            UIColor.random()
        ),
        (
            "mountain_peak",
            UIColor.random()
        ),
        (
            "park",
            UIColor.random()
        ),
        (
            "boundary",
            UIColor.random()
        ),
        (
            "aeroway",
            UIColor.random()
        ),
        (
            "transportation",
            UIColor.random()
        ),
        (
            "building",
            UIColor.random()
        ),
        (
            "water_name",
            UIColor.random()
        ),
        (
            "transportation_name",
            UIColor.random()
        ),
        (
            "place",
            UIColor.random()
        ),
        (
            "housenumber",
            UIColor.random()
        ),
        (
            "poi",
            UIColor.random()
        ),
        (
            "aerodrome_label",
            UIColor.random()
        )
    ]

    public var mapView: MTMapView!

    public var didUpdateStressTest: ((String) -> Void)?

    var initTime: CFAbsoluteTime!

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: MTBenchmark.self)
    )

    public init(frame: CGRect) async {
        await setUp(in: frame)
    }

    public func setAPIKey(apiKey: String) {
        self.apiKey = apiKey
    }

    public func start() async {
        await benchmarkSwift()
        await benchmarkJS()
    }

    public func startStressTest(iterations: Int, markersAreOn: Bool) async {
        let totalStartTime = CFAbsoluteTimeGetCurrent()

        await stressNavigation(iterations: iterations)

        if markersAreOn {
            await stressMarkers(iterations: iterations)
        }
        
        await stressSourcesAndLayers(iterations: iterations)

        let totalElapsedTime = CFAbsoluteTimeGetCurrent() - totalStartTime

        logger.log(level: .error, "TOTAL Benchmark t: \(totalElapsedTime)")
        didUpdateStressTest?(">>> TOTAL Benchmark elapsed: \(totalElapsedTime)")
    }

    private func setUp(in frame: CGRect) async {
        let mapOptions = MTMapOptions(center: centerCoordinate, zoom: zoom)
        initTime = CFAbsoluteTimeGetCurrent()
        logger.log(level: .error, "t: \(self.initTime) - MapViewInitStarted")
        mapView = MTMapView(frame: frame, options: mapOptions, referenceStyle: .streets, styleVariant: .defaultVariant)
        mapView.delegate = self
    }

    private func benchmarkSwiftExecution(label: String, block: @escaping () async -> Void) async {
        let startTime = CFAbsoluteTimeGetCurrent()
        await block()
        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
        logger.log(level: .error, "Swift: \(label)\nstart t: \(startTime)\nelapsed t: \(elapsedTime)")
    }

    private func benchmarkJSExecution(command: MTCommand) async {
        let startTime = CFAbsoluteTimeGetCurrent()
        await mapView.runCommand(command)
        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
        logger.log(level: .error, "t: \(elapsedTime) - \(command.toJS())")
    }

    public func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?) {
        logger.log(level: .info, "t: \(CFAbsoluteTimeGetCurrent()) - \(event.rawValue)")
    }

    public func mapViewDidInitialize(_ mapView: MTMapView) {
        let initEndedTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = initEndedTime - initTime
        logger.log(level: .error, "t: \(initEndedTime) - MapViewInitEnded")
        logger.log(level: .error, "t: \(elapsedTime) - MapViewInitElapsed")
    }

    private func benchmarkSwift() async {
        await benchmarkSwiftExecution(label: "Fibonacci 30") { [weak self] in
            guard let self else {
                return
            }

            func fibonacci(_ n: Int) -> Int {
                return n < 2 ? n : fibonacci(n - 1) + fibonacci(n - 2)
            }

            _ = fibonacci(30)
        }

        await benchmarkSwiftExecution(label: "Memory Allocation 100K") { [weak self] in
            guard let self else {
                return
            }

            let array = (0..<1_000_000).map { _ in
                UUID().uuidString
            }

            _ = array.count
        }
    }

    private func benchmarkJS() async {
        await benchmarkJSExecution(command: ZoomIn())
        await benchmarkJSExecution(command: ZoomOut())
        await benchmarkJSExecution(command: GetPitch())
        await benchmarkJSExecution(command: SetPitch(pitch: 2.0))

        let source = MTVectorTileSource(
            identifier: "planet-source",
            url: URL("https://api.maptiler.com/tiles/v3/tiles.json")!
        )
        await benchmarkJSExecution(command: AddSource(source: source))

        let layer = MTFillLayer(identifier: "planet-layer", sourceIdentifier: "planet-source")
        layer.color = .blue
        layer.sourceLayer = "default"
        await benchmarkJSExecution(command: AddLayer(layer: layer))
    }

    private func stressNavigation(iterations: Int) async {
        await stressZoom(iterations: iterations)
        await stressJumpTo(iterations: iterations)
        await stressFlyTo(iterations: iterations)
    }

    private func stressZoom(iterations: Int) async {
        var elapsedTimes: [CFAbsoluteTime] = []

        let totalStartTime = CFAbsoluteTimeGetCurrent()
        for i in 0...iterations {
            let startTime = CFAbsoluteTimeGetCurrent()
            await mapView.runCommand(i % 2 == 0 ? ZoomIn() : ZoomOut())
            let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            elapsedTimes.append(elapsedTime)
        }

        let elapsedTimesSum = elapsedTimes.reduce(0, +)
        let totalElapsedTime = CFAbsoluteTimeGetCurrent() - totalStartTime

        logger.log(level: .error, "total t: \(totalElapsedTime) - \("Zoom")")
        logger.log(level: .error, "avg t: \(elapsedTimesSum / Double(elapsedTimes.count)) - \("Zoom")")
        didUpdateStressTest?(">>> ZOOM Benchmark elapsed: \(totalElapsedTime)")
    }

    private func stressJumpTo(iterations: Int) async {
        var elapsedTimes: [CFAbsoluteTime] = []

        let totalStartTime = CFAbsoluteTimeGetCurrent()
        for i in 0...iterations {
            let startTime = CFAbsoluteTimeGetCurrent()
            let isEven = i % 2 == 0
            await mapView.runCommand(
                JumpTo(
                    center: CLLocationCoordinate2D(
                        latitude: isEven ? 19.567 : 45.567,
                        longitude: !isEven ? 19.567 : 45.567
                    )
                )
            )
            let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            elapsedTimes.append(elapsedTime)
        }

        let elapsedTimesSum = elapsedTimes.reduce(0, +)
        let totalElapsedTime = CFAbsoluteTimeGetCurrent() - totalStartTime

        logger.log(level: .error, "total t: \(totalElapsedTime) - \("JumpTo")")
        logger.log(level: .error, "avg t: \(elapsedTimesSum / Double(elapsedTimes.count)) - \("JumpTo")")
        didUpdateStressTest?(">>> JUMPTO Benchmark elapsed: \(totalElapsedTime)")
    }

    private func stressFlyTo(iterations: Int) async {
        var elapsedTimes: [CFAbsoluteTime] = []

        let totalStartTime = CFAbsoluteTimeGetCurrent()
        for i in 0...iterations {
            let startTime = CFAbsoluteTimeGetCurrent()
            let isEven = i % 2 == 0
            await mapView.runCommand(
                FlyTo(
                    center: CLLocationCoordinate2D(
                        latitude: isEven ? 19.567 : 45.567,
                        longitude: !isEven ? 19.567 : 45.567
                    )
                )
            )
            let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            elapsedTimes.append(elapsedTime)
        }

        let elapsedTimesSum = elapsedTimes.reduce(0, +)
        let totalElapsedTime = CFAbsoluteTimeGetCurrent() - totalStartTime

        logger.log(level: .error, "total t: \(totalElapsedTime) - \("FlyTo")")
        logger.log(level: .error, "avg t: \(elapsedTimesSum / Double(elapsedTimes.count)) - \("FlyTo")")
        didUpdateStressTest?(">>> FLYTO Benchmark elapsed: \(totalElapsedTime)")
    }

    private func stressMarkers(iterations: Int) async {
        // Edge Case
        // await stressMarkersClusteredDistribution(iterations: iterations)

        await stressMarkersRandomDistribution(iterations: iterations)
    }

    private func stressMarkersClusteredDistribution(iterations: Int) async {
        var elapsedTimes: [CFAbsoluteTime] = []

        let totalStartTime = CFAbsoluteTimeGetCurrent()
        for i in 0...iterations {
            let startTime = CFAbsoluteTimeGetCurrent()
            let isEven = i % 2 == 0
            let moduleThree: Double = Double(i % 3)

            let marker = MTMarker(
                coordinates: CLLocationCoordinate2D(
                    latitude: isEven ? 19.567 + moduleThree : 45.567 - moduleThree,
                    longitude: !isEven ? 19.567 + moduleThree : 45.567 - moduleThree
                )
            )
            await mapView.runCommand(AddMarker(marker: marker))
            let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            elapsedTimes.append(elapsedTime)
        }

        let elapsedTimesSum = elapsedTimes.reduce(0, +)
        let totalElapsedTime = CFAbsoluteTimeGetCurrent() - totalStartTime

        logger.log(level: .error, "total t: \(totalElapsedTime) - \("AddMarker")")
        logger.log(level: .error, "avg t: \(elapsedTimesSum / Double(elapsedTimes.count)) - \("AddMarker")")
    }

    private func stressMarkersRandomDistribution(iterations: Int) async {
        var elapsedTimes: [CFAbsoluteTime] = []

        let totalStartTime = CFAbsoluteTimeGetCurrent()
        for i in 0...iterations {
            let startTime = CFAbsoluteTimeGetCurrent()

            let lat = Double.random(in: -90...90)
            let lng = Double.random(in: -180...180)

            let marker = MTMarker(coordinates: CLLocationCoordinate2D(latitude: lat, longitude: lng))

            await mapView.runCommand(AddMarker(marker: marker))
            let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            elapsedTimes.append(elapsedTime)
        }

        let elapsedTimesSum = elapsedTimes.reduce(0, +)
        let totalElapsedTime = CFAbsoluteTimeGetCurrent() - totalStartTime

        logger.log(level: .error, "total t: \(totalElapsedTime) - \("AddMarker")")
        logger.log(level: .error, "avg t: \(elapsedTimesSum / Double(elapsedTimes.count)) - \("AddMarker")")
        didUpdateStressTest?(">>> MARKERS RND DIST Benchmark elapsed: \(totalElapsedTime)")
    }

    private func stressSourcesAndLayers(iterations: Int) async {
        // Edge case
        // await stressSingleSourceAndMultipleLayers(iterations: iterations)

        await stressMultipleSourceAndMultipleLayers(iterations: iterations)
    }

    private func stressSingleSourceAndMultipleLayers(iterations: Int) async {
        var elapsedTimes: [CFAbsoluteTime] = []

        let source = MTVectorTileSource(
            identifier: "bench-source",
            tiles: [URL(string: "https://api.maptiler.com/tiles/v3/tiles.json")!]
        )
        try? await mapView.style?.addSource(source)

        let totalStartTime = CFAbsoluteTimeGetCurrent()
        for i in 0...iterations {
            let startTime = CFAbsoluteTimeGetCurrent()

            let layer = MTFillLayer(identifier: "bench-layer\(i)", sourceIdentifier: "bench-source")
            layer.color = i % 2 == 0 ? .blue : .red
            layer.sourceLayer = "default"
            try? await mapView.style?.addLayer(layer)

            let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            elapsedTimes.append(elapsedTime)
        }

        let elapsedTimesSum = elapsedTimes.reduce(0, +)
        let totalElapsedTime = CFAbsoluteTimeGetCurrent() - totalStartTime

        logger.log(level: .error, "total t: \(totalElapsedTime) - \("SingleSourceAndLayers")")
        logger.log(level: .error, "avg t: \(elapsedTimesSum / Double(elapsedTimes.count)) - \("SingleSourceAndLayers")")
    }

    private func stressMultipleSourceAndMultipleLayers(iterations: Int) async {
        let sources: [(String, String, UIColor)] = [
            (
                "contour",
                "https://api.maptiler.com/tiles/contours-v2/{z}/{x}/{y}.pbf?key=\(apiKey)",
                .red.withAlphaComponent(0.2)
            ),
            (
                "administrative",
                "https://api.maptiler.com/tiles/countries/{z}/{x}/{y}.pbf?key=\(apiKey)",
                .white.withAlphaComponent(0.2)
            ),
            (
                "land",
                "https://api.maptiler.com/tiles/land/{z}/{x}/{y}.pbf?key=\(apiKey)",
                .blue.withAlphaComponent(0.2)
            ),
            (
                "contour",
                "https://api.maptiler.com/tiles/ocean/{z}/{x}/{y}.pbf?key=\(apiKey)",
                .green.withAlphaComponent(0.2)
            ),
            (
                "ski",
                "https://api.maptiler.com/tiles/outdoor/{z}/{x}/{y}.pbf?key=\(apiKey)",
                .orange.withAlphaComponent(0.2)
            ),
            (
                "batiments",
                "https://api.maptiler.com/tiles/fr-cadastre/{z}/{x}/{y}.pbf?key=\(apiKey)",
                .black.withAlphaComponent(0.2)
            ),
            (
                "building",
                "https://api.maptiler.com/tiles/ch-swisstopo-lbm/{z}/{x}/{y}.pbf?key=\(apiKey)",
                .lightGray.withAlphaComponent(0.2)
            )
        ]

        var elapsedTimes: [CFAbsoluteTime] = []

        let totalStartTime = CFAbsoluteTimeGetCurrent()
        for sourceTuple in sources {
            let startTime = CFAbsoluteTimeGetCurrent()

            let source = MTVectorTileSource(identifier: "source-\(sourceTuple.1)", tiles: [URL(string: sourceTuple.1)!])
            try? await mapView.style?.addSource(source)

            let layer = MTFillLayer(identifier: "layer-\(sourceTuple.1)", sourceIdentifier: "source-\(sourceTuple.1)")
            layer.color = sourceTuple.2
            layer.sourceLayer = sourceTuple.0
            try? await mapView.style?.addLayer(layer)

            let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            elapsedTimes.append(elapsedTime)
        }

        for sourceTuple in openMapTiles {
            let startTime = CFAbsoluteTimeGetCurrent()

            let source = MTVectorTileSource(
                identifier: "source-\(sourceTuple.0)",
                tiles: [URL(string: "https://api.maptiler.com/tiles/v3-openmaptiles/{z}/{x}/{y}.pbf?key=\(apiKey)")!]
            )
            try? await mapView.style?.addSource(source)

            let layer = MTFillLayer(identifier: "layer-\(sourceTuple.0)", sourceIdentifier: "source-\(sourceTuple.0)")
            layer.color = sourceTuple.1
            layer.sourceLayer = sourceTuple.0
            try? await mapView.style?.addLayer(layer)

            let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            elapsedTimes.append(elapsedTime)
        }

        for sourceTuple in openStackTiles {
            let startTime = CFAbsoluteTimeGetCurrent()

            let source = MTVectorTileSource(
                identifier: "source-\(sourceTuple.0)",
                tiles: [URL(string: "https://api.maptiler.com/tiles/uk-openzoomstack/{z}/{x}/{y}.pbf?key=\(apiKey)")!]
            )
            try? await mapView.style?.addSource(source)

            let layer = MTFillLayer(identifier: "layer-\(sourceTuple.0)", sourceIdentifier: "source-\(sourceTuple.0)")
            layer.color = sourceTuple.1
            layer.sourceLayer = sourceTuple.0
            try? await mapView.style?.addLayer(layer)

            let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            elapsedTimes.append(elapsedTime)
        }

        let elapsedTimesSum = elapsedTimes.reduce(0, +)
        let totalElapsedTime = CFAbsoluteTimeGetCurrent() - totalStartTime

        logger.log(level: .error, "total t: \(totalElapsedTime) - \("SourcesAndLayers")")
        logger.log(level: .error, "avg t: \(elapsedTimesSum / Double(elapsedTimes.count)) - \("SourcesAndLayers")")
        didUpdateStressTest?(">>> SOURCES AND LAYERS Benchmark elapsed: \(totalElapsedTime)")
    }
}

fileprivate extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

fileprivate extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red: .random(),
            green: .random(),
            blue: .random(),
            alpha: 1.0
        )
    }
}

// *** JS FPS SCRIPT  ***
// (function() {
//    let frameCount = 0;
//    let lastTime = performance.now();
//    let fps = 0;
//
//    function calculateFPS(now) {
//        frameCount++;
//        let delta = now - lastTime;
//
//        if (delta >= 1000) {
//            fps = frameCount;
//            frameCount = 0;
//            lastTime = now;
//        }
//        requestAnimationFrame(calculateFPS);
//    }
//
//    requestAnimationFrame(calculateFPS);
//    setInterval(() => {
//        window.webkit.messageHandlers.fpsHandler.postMessage(fps);
//    }, 1000);
// })();
// *** ***
// swiftlint:enable all
