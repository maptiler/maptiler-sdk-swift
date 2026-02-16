<img src="Examples/maptiler-logo.png" alt="Company Logo" height="32"/>

# MapTiler SDK Swift

The MapTiler SDK Swift is a native SDK written in Swift, designed to work with the well-established MapTiler Cloud service, which provides all the data required to fuel a complete mobile mapping experience: vector tiles, geojson, map interaction, custom styles, data visualization and more.

[![](https://img.shields.io/endpoint?style=for-the-badge&logo=swift&labelColor=D3DBEC&logoColor=333359&color=f2f6ff&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmaptiler%2Fmaptiler-sdk-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/maptiler/maptiler-sdk-swift) [![](https://img.shields.io/badge/Platforms-iOS-f2f6ff?style=for-the-badge&labelColor=D3DBEC&logo=apple&logoColor=333359)](https://swiftpackageindex.com/maptiler/maptiler-sdk-swift)

---

📖 [Documentation](https://docs.maptiler.com/mobile-sdk/ios/) &nbsp; 🌐 [Website](https://docs.maptiler.com/guides/getting-started/mobile/) &nbsp; 🔑 [Get API Key](https://cloud.maptiler.com/account/keys/)

---

<br>

<details> <summary><b>Table of Contents</b></summary>
<ul>
<li><a href="#-installation">Installation</a></li>
<li><a href="#-basic-usage">Basic Usage</a></li>
<li><a href="#-related-examples">Examples</a></li>
<li><a href="#-api-reference">API Reference</a></li>
<li><a href="#migration-guide">Migration Guide</a></li>
<li><a href="#-support">Support</a></li>
<li><a href="#-contributing">Contributing</a></li>
<li><a href="#-license">License</a></li>
<li><a href="#-acknowledgements">Acknowledgements</a></li>
</ul>
</details>

<p align="center">
<img src="Examples/streets.png" alt="MapTiler" title="MapTiler"/>
<img src="Examples/satellite.png" alt="MapTiler" title="MapTiler"/>
</p>
<br>

## 📦 Installation

MapTiler Swift SDK is a Swift Package and can be added as dependency through **Swift Package Manager**.

- File -> Add Package Dependencies
- Add https://github.com/maptiler/maptiler-sdk-swift.git

<br>

## 🚀 Basic Usage

Make sure to set your MapTiler Cloud API key first. (i.e. in AppDelegate):

```swift
Task {
    await MTConfig.shared.setAPIKey("YOUR_API_KEY")
}
```

### UIKit

```swift
import MapTilerSDK

let coordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
let options = MTMapOptions(center: coordinates, zoom: 2.0, bearing: 1.0, pitch: 20.0)
var mapView = MTMapView(frame: view.frame, options: options, referenceStyle: .streets)
mapView.delegate = self

view.addSubview(mapView)
```

If you are using auto layout, you can call the helper function for anchors pinning. This ensures correct orientation updates.

```swift
mapView.pinToSuperviewEdges()
```

### SwiftUI

```swift
import MapTilerSDK

@State private var mapView = MTMapView(options: MTMapOptions(zoom: 2.0))

var body: some View {
    MTMapViewContainer(map: mapView) {}
        .referenceStyle(.streets)
}
```

For detailed functionality overview refer to the API Reference documentation or build local docs in Xcode: Product -> Build Documentation.

<br>

## 💡 Related Examples

- [Getting Started](https://docs.maptiler.com/mobile-sdk/ios/examples/get-started/)
- [Globe with milkyway and halo](https://docs.maptiler.com/mobile-sdk/ios/examples/globe/)
- [Point Helper Clusters](https://docs.maptiler.com/mobile-sdk/ios/examples/point-helper-cluster/)

Check out the full list of [MapTiler SDK Swift examples](https://docs.maptiler.com/mobile-sdk/ios/examples/) or browse ready-to-use code examples at the [Examples](https://github.com/maptiler/maptiler-sdk-swift/tree/main/Examples) directory in this repo.

<br>

## 📘 API Reference

For detailed guides, API reference, and advanced examples, visit our comprehensive documentation:

[API documentation](https://docs.maptiler.com/mobile-sdk/ios/)

### Sources and Layers

Sources and layers can be added to the map view style object as soon as map is initialized. Setting the style after adding layers resets them to default, so make sure style is finished loading first.

#### UIKit

```swift
guard let style = mapView.style else {
    return
}

if let contoursTilesURL = URL(string: "https://api.maptiler.com/tiles/contours-v2/tiles.json?key=YOUR_API_KEY") {
    let contoursDataSource = MTVectorTileSource(identifier: "contoursSource", url: contoursTilesURL)
    style.addSource(contoursDataSource)

    let contoursLayer = MTLineLayer(identifier: "contoursLayer", sourceIdentifier: contoursDataSource.identifier, sourceLayer: "contour_ft")
    contoursLayer.color = .brown
    contoursLayer.width = 2.0

    style.addLayer(contoursLayer)
}
```

#### SwiftUI

```swift
@State private var mapView = MTMapView(options: MTMapOptions(zoom: 2.0))

var body: some View {
    MTMapViewContainer(map: mapView) {
        MTVectorTileSource(identifier: "countoursSource", url: URL(string: "https://api.maptiler.com/tiles/contours-v2/tiles.json?key=YOUR_API_KEY"))

        MTLineLayer(identifier: "contoursLayer", sourceIdentifier: "countoursSource", sourceLayer: "contour_ft")
            .color(.brown)
            .width(2.0)

    }
}
```

### Markers and Popups

Markers and popups (Text, Custom Annotation) can be used for highlighting points of interest on the map.

#### UIKit

```swift
let coordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)

let popup = MTTextPopup(coordinates: coordinates, text: "MapTiler", offset: 20.0)
let marker = MTMarker(coordinates: coordinates, popup: popup)
marker.draggable = true

mapView.addMarker(marker)
```

#### SwiftUI

```swift
@State private var mapView = MTMapView(options: MTMapOptions(zoom: 2.0))

let coordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)

var body: some View {
    MTMapViewContainer(map: mapView) {
        let popup = MTTextPopup(coordinates: coordinates, text: "MapTiler", offset: 20.0)

        MTMarker(coordinates: coordinates, draggable: true, popup: popup)
    }
}
```

Alternatively add content on custom actions:

```swift
@State private var mapView = MTMapView(options: MTMapOptions(zoom: 2.0))

let coordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)

var body: some View {
    MTMapViewContainer(map: mapView) {
    }
        .didInitialize {
            let marker = MTMarker(coordinates: coordinates)

            Task {
                await mapView.addMarker(marker)
            }
        }

    Button("Add Popup") {
        Task {
            let popup = MTTextPopup(coordinates: coordinates, text: "MapTiler", offset: 20.0)

            await mapView.addTextPopup(popup)
        }
    }
}
```

For additional examples refer to the Examples directory.

### Custom Annotations

In addition to `MTMarker` and `MTTextPopup`, you can use `MTCustomAnnotationView` class to make your own annotations and add them to the map. You can subclass to create custom UI it or use it as is for simple designs.

```swift
let customSize = CGSize(width: 200.0, height: 80.0)
let coordinates = CLLocationCoordinate2D(latitude: 47.137765, longitude: 8.581651)
let offset = MTPoint(x: 0, y: -80)

let myCustomView = MTCustomAnnotationView(size: customSize, coordinates: coordinates, offset: offset)
myCustomView.backgroundColor = .blue

myCustomView.addTo(mapView)
```

### Space

The space option customizes the globe’s background, simulating deep space or skybox effects.

- Prerequisite: use globe projection. Set `projection: .globe` in `MTMapOptions`.

Usage — solid color background

```swift
import MapTilerSDK

// UIKit
let options = MTMapOptions(
    projection: .globe,
    space: .config(
        MTSpace(
            color: MTColor(color: UIColor(hex: "#111122")!.cgColor)
        )
    )
)
let mapView = MTMapView(frame: view.bounds, options: options, referenceStyle: .streets)

// SwiftUI
@State private var mapView = MTMapView(
    options: MTMapOptions(
        projection: .globe,
        space: .config(MTSpace(color: MTColor(color: UIColor(hex: "#111122")!.cgColor)))
    )
)
```

Presets — predefined cubemaps

- `space`: Dark blue background; stars stay white. Space color changes background color.
- `stars` (default): Black background; space color changes stars color.
- `milkyway`: Black half‑transparent background with standard milky way and stars; space color tints stars and milky way.
- `milkyway-subtle`: Subtle milky way, fewer stars; space color tints stars and milky way.
- `milkyway-bright`: Bright milky way, more stars; space color tints stars and milky way.
- `milkyway-colored`: Full image with natural colors; space color has no effect.

```swift
// Use a preset
let options = MTMapOptions(
    projection: .globe,
    space: .config(MTSpace(preset: .space))
)
```

Custom cubemap — provide all faces

```swift
let faces = MTSpaceFaces(
    pX: URL(string: "https://example.com/space/px.png")!,
    nX: URL(string: "https://example.com/space/nx.png")!,
    pY: URL(string: "https://example.com/space/py.png")!,
    nY: URL(string: "https://example.com/space/ny.png")!,
    pZ: URL(string: "https://example.com/space/pz.png")!,
    nZ: URL(string: "https://example.com/space/nz.png")!
)

let options = MTMapOptions(
    projection: .globe,
    space: .config(MTSpace(faces: faces))
)
```

Cubemap by path — files named px, nx, py, ny, pz, nz with the given format

```swift
let path = MTSpacePath(
    baseUrl: URL(string: "https://example.com/spacebox/transparent")!,
    format: "png" // defaults to PNG if omitted
)

let options = MTMapOptions(
    projection: .globe,
    space: .config(MTSpace(path: path))
)
```

Dynamic updates — change space at runtime

```swift
mapView.didInitialize = {
    Task {
        await mapView.setSpace(
            .config(
                MTSpace(
                    color: MTColor(color: UIColor.red.cgColor),
                    path: MTSpacePath(baseUrl: URL(string: "https://example.com/spacebox/transparent")!)
                )
            )
        )
    }
}
```

Note: When calling `setSpace`, any field not explicitly provided (e.g., `color`, `faces`, `path`, or `preset`) keeps its previous value.

### Halo

The halo option adds a gradient-based atmospheric glow around the globe, simulating the visual effect of Earth's atmosphere when viewed from space.

- Prerequisite: use globe projection. Set `projection: .globe` in `MTMapOptions`.

Usage — enable simple halo

```swift
import MapTilerSDK

// UIKit
let options = MTMapOptions(
    projection: .globe,
    halo: .enabled(true)
)
let mapView = MTMapView(frame: view.bounds, options: options, referenceStyle: .outdoor)

// SwiftUI
@State private var mapView = MTMapView(
    options: MTMapOptions(
        projection: .globe,
        halo: .enabled(true)
    )
)
```

Custom gradient — scale and stops

```swift
let options = MTMapOptions(
    projection: .globe,
    halo: .config(
        MTHalo(
            scale: 1.5, // Controls the halo size
            stops: [
                MTHaloStop(position: 0.2, color: MTColor(hex: "#00000000")),
                MTHaloStop(position: 0.2, color: MTColor(hex: "#FF0000")),
                MTHaloStop(position: 0.4, color: MTColor(hex: "#FF0000")),
                MTHaloStop(position: 0.4, color: MTColor(hex: "#00000000")),
                MTHaloStop(position: 0.6, color: MTColor(hex: "#00000000")),
                MTHaloStop(position: 0.6, color: MTColor(hex: "#FF0000")),
                MTHaloStop(position: 0.8, color: MTColor(hex: "#FF0000")),
                MTHaloStop(position: 0.8, color: MTColor(hex: "#00000000")),
                MTHaloStop(position: 1.0, color: MTColor(hex: "#00000000"))
            ]
        )
    )
)
```

Dynamic updates — change halo at runtime

```swift
mapView.didInitialize = {
    Task {
        await mapView.setHalo(
            .config(
                MTHalo(
                    scale: 2.0,
                    stops: [
                        MTHaloStop(position: 0.0, color: MTColor(hex: "#87CEFA")),
                        MTHaloStop(position: 0.5, color: MTColor(hex: "#0000FABF")),
                        MTHaloStop(position: 0.75, color: MTColor(hex: "#FF000000"))
                    ]
                )
            )
        )
    }
}
```

Disable animations — halo and space

```swift
mapView.didInitialize = {
    Task {
        await mapView.disableHaloAnimations()
        await mapView.disableSpaceAnimations()
    }
}
```

<br>

## Migration Guide

- [How To Migrate/Switch From MapBox iOS SDK to MapTiler SDK Swift](https://docs.maptiler.com/mobile-sdk/ios/examples/switch-from-mapbox/)
- [How To Migrate/Switch From MapLibre Native iOS to MapTiler SDK Swift](https://docs.maptiler.com/mobile-sdk/ios/examples/switch-from-maplibre/)

<br>

## 💬 Support

- 📚 [Documentation](https://docs.maptiler.com/mobile-sdk/ios/) - Comprehensive guides and API reference
- ✉️ [Contact us](https://maptiler.com/contact) - Get in touch or submit a request
- 🐦 [Twitter/X](https://twitter.com/maptiler) - Follow us for updates

<br>

---

<br>

## 🤝 Contributing

We love contributions from the community! Whether it's bug reports, feature requests, or pull requests, all contributions are welcome:

- Fork the repository and create your branch from `main`
- If you've added code, add tests that cover your changes
- Ensure your code follows our style guidelines
- Give your pull request a clear, descriptive summary
- Open a Pull Request with a comprehensive description
- Read the [CONTRIBUTING](./CONTRIBUTING.md) file

<br>

## 📄 License

MapTiler SDK Swift is released under the BSD 3-Clause license – see the [LICENSE](./LICENSE) file for details.

<br>

## 🙏 Acknowledgements

### Features

- [x] Map interaction
- [x] Pre-made map styles
- [x] Sources: Vector tiles, Raster tiles, Raster DEM (terrain), GeoJSON, Image, Video
- [x] Layers: Background, Fill, Line, Symbol, Circle, Raster, Heatmap, Hillshade, Fill Extrusion
- [x] Custom Annotation Views
- [x] Location tracking
- [x] Globe and 3D Terrain
- [x] UIKit and SwiftUI support

<br>

<p align="center" style="margin-top:20px;margin-bottom:20px;"> <a href="https://cloud.maptiler.com/account/keys/" style="display:inline-block;padding:12px 32px;background:#F2F6FF;color:#000;font-weight:bold;border-radius:6px;text-decoration:none;"> Get Your API Key <sup style="background-color:#0000ff;color:#fff;padding:2px 6px;font-size:12px;border-radius:3px;">FREE</sup><br /> <span style="font-size:90%;font-weight:400;">Start building with 100,000 free map loads per month ・ No credit card required.</span> </a> </p>

<br>

<p align="center"> 💜 Made with love by the <a href="https://www.maptiler.com/">MapTiler</a> team <br />
<p align="center">
  <a href="https://www.maptiler.com/">Website</a> •
  <a href="https://docs.maptiler.com/mobile-sdk/ios/">Documentation</a> •
  <a href="https://github.com/maptiler/maptiler-sdk-swift">GitHub</a>
</p>
