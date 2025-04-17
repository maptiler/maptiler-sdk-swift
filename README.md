
# MapTiler SDK Swift

The MapTiler SDK Swift is a native SDK written in Swift, designed to work with the well-established MapTiler Cloud service, which provides all the data required to fuel a complete mobile mapping experience: vector tiles, geojson, map interaction, custom styles and more.

## Features
- [x] Map interaction
- [x] Pre-made map styles
- [x] VectorTile and GeoJSON sources
- [x] Fill, Line and Symbol layers
- [x] Custom Annotation Views
- [x] UIKit and SwiftUI support
- [x] Location tracking
- [x] Globe and 3D Terrain

## Basic Usage

### UIKit

```
import MapTilerSDK

let options = MTMapOptions(center: Constants.unterageriCoordinates, zoom: Constants.defaultZoomLevel, bearing: 1.0, pitch: 20.0)
var mapView = MTMapView(frame: view.frame, options: options, referenceStyle: .streets)
mapView.delegate = self

view.addSubview(mapView)
```

### SwiftUI

```
import MapTilerSDK

@State private var referenceStyle: MTMapReferenceStyle = .streets
@State private var styleVariant: MTMapStyleVariant? = .defaultVariant

@State private var mapView = MTMapView(options: MTMapOptions(zoom: 14.0))

var body: some View {
    MTMapViewContainer(map: map) {}
        .referenceStyle(referenceStyle)
        .styleVariant(styleVariant)
}
```

For detailed functionality overview refer to the API Reference documentation. 

# Installation
MapTiler Swift SDK is a Swift Package and be added as dependecy through **Swift Package Manager**.

- File -> Add Package Dependencies
- Add https://github.com/maptiler/maptiler-sdk-swift.git