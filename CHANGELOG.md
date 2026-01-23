# Changelog
All notable changes to this project will be documented in this file.

## [1.2.1](https://github.com/maptiler/maptiler-sdk-swift/releases/tag/1.2.1)
Released on 2025-01-23.
### Fixed
Bridging performance regression introduced in iOS 26.2 patched.

## [1.2.0](https://github.com/maptiler/maptiler-sdk-swift/releases/tag/1.2.0)
Released on 2025-12-12.
### Added
- Raster source: Custom raster and raster DEM data can now be added to the map.
- Raster layer: New raster layer allows visualization of custom raster data.
- MTCircle layer: Added new type of layer for visualizing data as circles.
- Clustering filters: MTCircle and MTSymbol layers now support clustering filters and expressions.

## [1.1.0](https://github.com/maptiler/maptiler-sdk-swift/releases/tag/1.1.0)
Released on 2025-10-14.
### Added
- Space: The space option allows customizing the background environment of the globe, simulating deep space or skybox effects.
- Halo: The halo option adds a gradient-based atmospheric glow around the globe, simulating the visual effect of Earth's atmosphere when viewed from space.
### Fixed
- Xcode 26 build issues pertaining to MTInternalLogger class mitigated.

## [1.0.2](https://github.com/maptiler/maptiler-sdk-swift/releases/tag/1.0.2)
Released on 2025-07-22.
### Fixed
- Bug with using `.ignoreSafeArea()` on `MTMapViewContainer` is now fixed and layout is properly propagated.

## [1.0.1](https://github.com/maptiler/maptiler-sdk-swift/releases/tag/1.0.1)
Released on 2025-06-05.
### Fixed
- Potential bug with MTSource and MTLayer insertion before style is loaded is now fixed.

## [1.0.0](https://github.com/maptiler/maptiler-sdk-swift/releases/tag/1.0.0)
Released on 2025-05-14.
### Added
- Initial public release