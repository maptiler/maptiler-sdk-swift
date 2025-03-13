//
//  MTBenchmark.swift
//  MapTilerSDK
//

import CoreLocation
import os

// Overview of performance.
// Detailed benchmarking is performed by Benchmarking package.
public final class MTBenchmark: MTMapViewDelegate {
    let zoom = 6.0
    let centerCoordinate = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)

    public var mapView: MTMapView!

    var initTime: CFAbsoluteTime!

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: MTBenchmark.self)
    )

    public init(frame: CGRect) async {
        await setUp(in: frame)
    }

    public func start() async {
        await benchmarkSwift()
        await benchmarkJS()
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
//        logger.log(level: .info, "t: \(CFAbsoluteTimeGetCurrent()) - \(event.rawValue)")
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

        let source = MTVectorTileSource(identifier: "planet-source", url: URL("https://api.maptiler.com/tiles/v3/tiles.json")!)
        await benchmarkJSExecution(command: AddSource(source: source))

        let layer = MTFillLayer(identifier: "planet-layer", sourceIdentifier: "planet-source")
        layer.color = .blue
        layer.sourceLayer = "default"
        await benchmarkJSExecution(command: AddLayer(layer: layer))
    }
}

// *** JS FPS SCRIPT  ***
//(function() {
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
//})();
// *** ***
