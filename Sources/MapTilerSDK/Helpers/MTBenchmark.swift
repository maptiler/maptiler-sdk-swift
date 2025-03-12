//
//  MTBenchmark.swift
//  MapTilerSDK
//

import CoreLocation
import os

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
        // *** EXAMPLE ***
//        await benchmarkSwiftExecution(label: "Zoom In") { [weak self] in
//            guard let self else {
//                return
//            }
//
//            await mapView.zoomIn()
//        }
        // *** ***
    }

    private func setUp(in frame: CGRect) async {
        let mapOptions = MTMapOptions(center: centerCoordinate, zoom: zoom)
        initTime = CFAbsoluteTimeGetCurrent()
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
        let elapsedTime = CFAbsoluteTimeGetCurrent() - initTime
        logger.log(level: .error, "t: \(elapsedTime) - MapViewInit")
    }
}
