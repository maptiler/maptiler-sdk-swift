//
//  Clustering+UIKit.swift
//  MapTilerSDK Examples
//

import UIKit
import CoreLocation
import MapTilerSDK

final class ClusteringUIKitExampleViewController: UIViewController {
    private var mapView: MTMapView!

    private let sourceId = "earthquakes"
    private let clustersLayerId = "clusters"
    private let clusterCountLayerId = "clusterCount"
    private let unclusteredLayerId = "unclusteredPoint"

    override func viewDidLoad() {
        super.viewDidLoad()
        Task { await MTConfig.shared.setAPIKey("YOUR_API_KEY") }
        let options = MTMapOptions(center: CLLocationCoordinate2D(latitude: 20, longitude: 0), zoom: 0.3)
        mapView = MTMapView(frame: view.bounds, options: options, referenceStyle: .dataviz, styleVariant: .dark)
        view.addSubview(mapView)

        Task { await setupClustering() }
    }

    private func setupClustering() async {
        guard let style = mapView.style else { return }

        // Clustered source
        let src = MTGeoJSONSource(
            identifier: sourceId,
            url: URL(string: "https://docs.maptiler.com/sdk-js/assets/earthquakes.geojson")!,
            isCluster: true,
            clusterMaxZoom: 14,
            clusterRadius: 50
        )
        try? await style.addSource(src)

        // Cluster bubbles (circles)
        let clusters = MTCircleLayer(identifier: clustersLayerId, sourceIdentifier: sourceId)
        clusters.strokeColor = .white
        clusters.strokeWidth = 2
        clusters.pitchAlignment = .viewport
        clusters.pitchScale = .map
        clusters.filterExpression = MTFilter.clusters()
        clusters.color = .expression(MTExpression.step(
            input: MTExpression.get(.pointCount),
            default: .color(UIColor(hex: "#51bbd6") ?? .systemTeal),
            stops: [
                (100, .color(UIColor(hex: "#f1f075") ?? .systemYellow)),
                (750, .color(UIColor(hex: "#f28cb1") ?? .systemPink))
            ]
        ))
        clusters.radius = .expression(MTExpression.step(
            input: MTExpression.get(.pointCount),
            default: .number(20),
            stops: [ (100, .number(30)), (750, .number(40)) ]
        ))
        try? await style.addLayer(clusters)

        // Cluster counts (symbols)
        let count = MTSymbolLayer(identifier: clusterCountLayerId, sourceIdentifier: sourceId)
        count.filterExpression = MTFilter.clusters()
        count.textField = MTTextToken.pointCountAbbreviated.rawValue
        count.textSize = 12
        count.textAllowOverlap = true
        count.textAnchor = .center
        count.textFont = ["DIN Offc Pro Medium", "Arial Unicode MS Bold"]
        count.textColor = .white
        try? await style.addLayer(count)

        // Unclustered points (circles)
        let unclustered = MTCircleLayer(identifier: unclusteredLayerId, sourceIdentifier: sourceId)
        unclustered.color = .color(UIColor(hex: "#11b4da") ?? .systemBlue)
        unclustered.radius = .number(4)
        unclustered.strokeColor = .white
        unclustered.strokeWidth = 1
        unclustered.filterExpression = MTFilter.unclustered()
        try? await style.addLayer(unclustered)
    }
}
