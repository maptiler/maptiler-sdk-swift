
# MapTiler SDK Swift
<p align="center">
<img src="Examples/maptiler-logo.png" alt="MapTiler" title="MapTiler"/>
</p>
<p align="center">
<img src="https://img.shields.io/badge/Swift-5.9_5.10_6.0-Orange?style=flat-square" alt="SPM" title="SPM"/>
<img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg" alt="SPM" title="SPM"/>
</p>

The MapTiler SDK Swift is a native SDK written in Swift, designed to work with the well-established MapTiler Cloud service, which provides all the data required to fuel a complete mobile mapping experience: vector tiles, geojson, map interaction, custom styles and more.

## Features
- [x] Map interaction
- [x] Pre-made map styles
- [x] VectorTile and GeoJSON sources
- [x] Fill, Line and Symbol layers
- [x] Custom Annotation Views
- [x] Location tracking
- [x] Globe and 3D Terrain
- [x] UIKit and SwiftUI support

## Basic Usage

Make sure to set your MapTiler Cloud API key first. (i.e. in AppDelegate):

```
MTConfig.shared.setAPIKey("YOUR_API_KEY")
```

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
MapTiler Swift SDK is a Swift Package and can be added as dependecy through **Swift Package Manager**.

- File -> Add Package Dependencies
- Add https://github.com/maptiler/maptiler-sdk-swift.git

<p align="center">
<img src="Examples/streets.png" alt="MapTiler" title="MapTiler"/>
<img src="Examples/satellite.png" alt="MapTiler" title="MapTiler"/>
</p>