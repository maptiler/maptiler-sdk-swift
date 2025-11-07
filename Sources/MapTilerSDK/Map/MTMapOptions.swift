//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapOptions.swift
//  MapTilerSDK
//

import Foundation
import CoreLocation

/// Parameters of the map object.
public struct MTMapOptions: Sendable {
    /// The language of the map.
    ///
    /// This applies only for the map instance, supersedes the primaryLanguage from config.
    public private(set) var language: MTLanguage?

    /// The geographical centerpoint of the map.
    ///
    /// If center is not specified, SDK will look for it in the map style object.
    /// If it is not specified in the style, it will default to (latitude: 0.0, longitude: 0.0).
    public private(set) var center: CLLocationCoordinate2D?

    /// Geographic bounds that should be visible by default when the map loads.
    public private(set) var bounds: MTBounds?

    /// Projection type of the map object.
    ///
    /// This will overwrite the projection property from the style (if any).
    public private(set) var projection: MTProjectionType?

    /// The zoom level of the map.
    ///
    /// If zoom is not specified, SDK will look for it in the map style object.
    /// If it is not specified in the style, it will default to 0.0.
    public private(set) var zoom: Double?

    /// The maximum zoom level of the map (0-24).
    public private(set) var maxZoom: Double?

    /// The minimum zoom level of the map (0-24).
    public private(set) var minZoom: Double?

    /// Maximum geographical bounds that the user can pan the map to.
    public private(set) var maxBounds: MTBounds?

    /// The bearing of the map, measured in degrees counter-clockwise from north.
    ///
    /// If bearing is not specified, SDK will look for it in the map style object.
    /// If it is not specified in the style, it will default to 0.0.
    public private(set) var bearing: Double?

    /// The threshold, measured in degrees, that determines when the map's bearing will snap to north.
    public private(set) var bearingSnap: Double?

    /// The pitch (tilt) of the map, measured in degrees away from the plane of the screen (0-85).
    ///
    /// If pitch is not specified, SDK will look for it in the map style object.
    /// If it is not specified in the style, it will default to 0.0.
    public private(set) var pitch: Double?

    /// The maximum pitch of the map (0-180).
    public private(set) var maxPitch: Double?

    /// The minimum pitch of the map (0-85).
    public private(set) var minPitch: Double?

    /// The roll angle of the map, measured in degrees counter-clockwise about the camera boresight.
    ///
    /// If roll is not specified, SDK will look for it in the map style object.
    /// If it is not specified in the style, it will default to 0.0.
    public private(set) var roll: Double?

    /// Boolean indicating whether the map's roll control with "drag to rotate" interaction is enabled.
    public private(set) var rollIsEnabled: Bool?

    /// The elevation of the geographical centerpoint of the map, in meters above sea level.
    ///
    /// If elevation is not specified, SDK will look for it in the map style object.
    /// If it is not specified in the style, it will default to 0.0.
    public private(set) var elevation: Double?

    /// Boolean indicating whether 3D terrain is enabled.
    public private(set) var terrainIsEnabled: Bool?

    /// 3D terrain exaggeration factor.
    public private(set) var terrainExaggeration: Double?

    /// Determines whether to cancel, or retain, tiles from the current viewport which are still loading
    /// but which belong to a farther (smaller) zoom level than the current one.
    ///
    /// If true, when zooming in, tiles which didn't manage to load for previous zoom levels will become canceled.
    /// This might save some computing resources for slower devices, but the map details might appear more
    /// abruptly at the end of the zoom. If false, when zooming in, the previous zoom level(s) tiles will progressively
    /// appear, giving a smoother map details experience. However, more tiles will be rendered
    /// in a short period of time.
    public private(set) var cancelPendingTileRequestsWhileZooming: Bool?

    /// Boolen indicating whether center is clamped to the ground.
    ///
    /// If true, the elevation of the center point will automatically be set to the terrain elevation
    /// (or zero if terrain is not enabled). If false, the elevation of the center point will default
    /// to sea level and will not automatically update.
    /// Needs to be set to false to keep the camera above ground when pitch > 90 degrees.
    public private(set) var isCenterClampedToGround: Bool?

    /// Boolean indicating whether Resource Timing API information will be collected.
    public private(set) var shouldCollectResourceTiming: Bool?

    /// Boolean indicating whether cross source collisions are enabled.
    ///
    /// If true, symbols from multiple sources can collide with each other during collision detection.
    /// If false, collision detection is run separately for the symbols in each source.
    public private(set) var crossSourceCollisionsAreEnabled: Bool?

    /// The duration of the fade-in/fade-out animation for label collisions, in milliseconds.
    ///
    /// This setting affects all symbol layers. This setting does not affect the duration of runtime
    /// styling transitions or raster tile cross-fading.
    public private(set) var fadeDuration: Double?

    // Boolean indicating whether interaction on the map is enabled.
    public private(set) var isInteractionEnabled: Bool?

    /// A value representing the position of the MapTiler wordmark on the map.
    public private(set) var logoPosition: MTMapCorner? = .topRight

    /// Boolean indicating whether MapTiler logo is visible on the map.
    ///
    /// If true, the MapTiler logo will be shown. false will only work on premium accounts
    public private(set) var maptilerLogoIsVisible: Bool?

    /// The maximum number of tiles stored in the tile cache for a given source.
    ///
    /// If omitted, the cache will be dynamically sized based on the current viewport.
    public private(set) var maxTileCacheSize: Double?

    /// The maximum number of zoom levels for which to store tiles for a given source.
    ///
    /// Tile cache dynamic size is calculated by multiplying maxTileCacheZoomLevels
    /// with the approximate number of tiles in the viewport for a given source.
    public private(set) var maxTileCacheZoomLevels: Double?

    /// Boolean indicating whether the map's pitch control
    /// with drag to rotate interaction will be disabled.
    public private(set) var shouldPitchWithRotate: Bool?

    /// Boolean indicating whether the map won't attempt to re-request tiles once they expire.
    public private(set) var shouldRefreshExpiredTiles: Bool?

    /// Boolean indicating whether multiple copies of the world will be rendered side by side
    /// beyond -180 and 180 degrees longitude.
    public private(set) var shouldRenderWorldCopies: Bool?

    /// Boolean indicating whether the drag to pitch" nteraction is enabled.
    public private(set) var shouldDragToPitch: Bool?

    /// Boolean indicating whether the pinch to rotate and zoom interaction is enabled.
    public private(set) var shouldPinchToRotateAndZoom: Bool?

    /// Boolean indicating whether the double tap to zoom interaction is enabled.
    public private(set) var doubleTapShouldZoom: Bool?

    /// Boolean indicating whether the drag to pan interaction is enabled.
    public private(set) var dragPanIsEnabled: Bool?

    /// Boolean indicating whether the drag to rotate interaction is enabled.
    public private(set) var dragRotateIsEnabled: Bool?

    /// Boolean indicating whether style should be validated.
    ///
    /// Useful in production environment.
    public private(set) var shouldValidateStyle: Bool?

    /// Boolean indicating whether minimap control is added directly to the map.
    public private(set) var minimapIsVisible: Bool? = false

    /// Boolean indicating whether attribution control is added directly to the map.
    public private(set) var attributionControlIsVisible: Bool?

    /// Boolean indicating whether geolocate control is added directly to the map.
    public private(set) var geolocateControlIsVisible: Bool? = false

    /// Boolean indicating whether navigation control is added directly to the map.
    public private(set) var navigationControlIsVisible: Bool? = false

    /// Boolean indicating whether projection control is added directly to the map.
    public private(set) var projectionControlIsVisible: Bool? = false

    /// Boolean indicating whether scale control is added directly to the map.
    public private(set) var scaleControlIsVisible: Bool? = false

    /// Boolean indicating whether terrain control is added directly to the map.
    public private(set) var terrainControlIsVisible: Bool? = false

    /// Boolean indicating whether session logic is enabled.
    ///
    /// This allows MapTiler to enable "session based billing".
    ///  - Note: Defaults to true.
    ///  - SeeAlso: ``https://docs.maptiler.com/guides/maps-apis/maps-platform/what-is-map-session-in-maptiler-cloud/``
    public private(set) var isSessionLogicEnabled: Bool = true

    /// Space background configuration for globe (cubemap/spacebox).
    public private(set) var space: MTSpaceOption?

    /// Atmospheric glow (halo) configuration for globe.
    public private(set) var halo: MTHaloOption?

    /// Initializes the map options with center and zoom.
    public init(center: CLLocationCoordinate2D?, zoom: Double?) {
        self.center = center
        self.zoom = zoom
    }

    /// Initializes the map options with center, zoom and terrain.
    public init(center: CLLocationCoordinate2D?, zoom: Double?, terrainIsEnabled: Bool?, terrainExaggeration: Double?) {
        self.center = center
        self.zoom = zoom
        self.terrainIsEnabled = terrainIsEnabled
        self.terrainExaggeration = terrainExaggeration
    }

    /// Initializes the map options with center, zoom and projection.
    public init(center: CLLocationCoordinate2D?, zoom: Double?, projection: MTProjectionType?) {
        self.center = center
        self.zoom = zoom
        self.projection = projection
    }

    /// Initializes the map options with center, zoom, bearing, and pitch.
    public init(center: CLLocationCoordinate2D?, zoom: Double?, bearing: Double?, pitch: Double?) {
        self.center = center
        self.zoom = zoom
        self.bearing = bearing
        self.pitch = pitch
    }

    /// Initializes the map options.
    public init(
        language: MTLanguage? = nil,
        center: CLLocationCoordinate2D? = nil,
        bounds: MTBounds? = nil,
        projection: MTProjectionType? = nil,
        zoom: Double? = nil,
        maxZoom: Double? = nil,
        minZoom: Double? = nil,
        maxBounds: MTBounds? = nil,
        bearing: Double? = nil,
        bearingSnap: Double? = nil,
        pitch: Double? = nil,
        maxPitch: Double? = nil,
        minPitch: Double? = nil,
        roll: Double? = nil,
        rollIsEnabled: Bool? = nil,
        elevation: Double? = nil,
        terrainIsEnabled: Bool? = nil,
        terrainExaggeration: Double? = nil,
        cancelPendingTileRequestsWhileZooming: Bool? = nil,
        isCenterClampedToGround: Bool? = nil,
        shouldCollectResourceTiming: Bool? = nil,
        crossSourceCollisionsAreEnabled: Bool? = nil,
        fadeDuration: Double? = nil,
        isInteractionEnabled: Bool? = nil,
        logoPosition: MTMapCorner? = nil,
        maptilerLogoIsVisible: Bool? = nil,
        maxTileCacheSize: Double? = nil,
        maxTileCacheZoomLevels: Double? = nil,
        shouldPitchWithRotate: Bool? = nil,
        shouldRefreshExpiredTiles: Bool? = nil,
        shouldRenderWorldCopies: Bool? = nil,
        shouldDragToPitch: Bool? = nil,
        shouldPinchToRotateAndZoom: Bool? = nil,
        doubleTapShouldZoom: Bool? = nil,
        dragPanIsEnabled: Bool? = nil,
        dragRotateIsEnabled: Bool? = nil,
        shouldValidateStyle: Bool? = nil,
        minimapIsVisible: Bool? = false,
        attributionControlIsVisible: Bool? = nil,
        geolocateControlIsVisible: Bool? = false,
        navigationControlIsVisible: Bool? = false,
        projectionControlIsVisible: Bool? = false,
        scaleControlIsVisible: Bool? = false,
        terrainControlIsVisible: Bool? = false,
        isSessionLogicEnabled: Bool = true,
        space: MTSpaceOption? = nil,
        halo: MTHaloOption? = nil
    ) {
        self.language = language
        self.center = center
        self.bounds = bounds
        self.projection = projection
        self.zoom = zoom
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.maxBounds = maxBounds
        self.bearing = bearing
        self.bearingSnap = bearingSnap
        self.pitch = pitch
        self.maxPitch = maxPitch
        self.minPitch = minPitch
        self.roll = roll
        self.rollIsEnabled = rollIsEnabled
        self.elevation = elevation
        self.terrainIsEnabled = terrainIsEnabled
        self.terrainExaggeration = terrainExaggeration
        self.cancelPendingTileRequestsWhileZooming = cancelPendingTileRequestsWhileZooming
        self.isCenterClampedToGround = isCenterClampedToGround
        self.shouldCollectResourceTiming = shouldCollectResourceTiming
        self.crossSourceCollisionsAreEnabled = crossSourceCollisionsAreEnabled
        self.fadeDuration = fadeDuration
        self.isInteractionEnabled = isInteractionEnabled
        self.logoPosition = logoPosition
        self.maptilerLogoIsVisible = maptilerLogoIsVisible
        self.maxTileCacheSize = maxTileCacheSize
        self.maxTileCacheZoomLevels = maxTileCacheZoomLevels
        self.shouldPitchWithRotate = shouldPitchWithRotate
        self.shouldRefreshExpiredTiles = shouldRefreshExpiredTiles
        self.shouldRenderWorldCopies = shouldRenderWorldCopies
        self.shouldDragToPitch = shouldDragToPitch
        self.shouldPinchToRotateAndZoom = shouldPinchToRotateAndZoom
        self.doubleTapShouldZoom = doubleTapShouldZoom
        self.dragPanIsEnabled = dragPanIsEnabled
        self.dragRotateIsEnabled = dragRotateIsEnabled
        self.shouldValidateStyle = shouldValidateStyle
        self.minimapIsVisible = minimapIsVisible
        self.attributionControlIsVisible = attributionControlIsVisible
        self.geolocateControlIsVisible = geolocateControlIsVisible
        self.navigationControlIsVisible = navigationControlIsVisible
        self.projectionControlIsVisible = projectionControlIsVisible
        self.scaleControlIsVisible = scaleControlIsVisible
        self.terrainControlIsVisible = terrainControlIsVisible
        self.isSessionLogicEnabled = isSessionLogicEnabled
        self.space = space
        self.halo = halo
    }
}

extension MTMapOptions: Codable {
    package enum CodingKeys: String, CodingKey {
        case language
        case center
        case bounds
        case projection
        case zoom
        case maxZoom
        case minZoom
        case maxBounds
        case bearing
        case bearingSnap
        case pitch
        case maxPitch
        case minPitch
        case roll
        case rollIsEnabled = "rollEnabled"
        case elevation
        case terrainIsEnabled = "terrain"
        case terrainExaggeration
        case cancelPendingTileRequestsWhileZooming
        case isCenterClampedToGround = "centerClampedToGround"
        case shouldCollectResourceTiming = "collectResourceTiming"
        case crossSourceCollisionsAreEnabled = "crossSourceCollisions"
        case fadeDuration
        case isInteractionEnabled = "interactive"
        case logoPosition
        case maptilerLogoIsVisible = "maptilerLogo"
        case maxTileCacheSize
        case maxTileCacheZoomLevels
        case shouldPitchWithRotate = "pitchWithRotate"
        case shouldRefreshExpiredTiles = "refreshExpiredTiles"
        case shouldRenderWorldCopies = "renderWorldCopies"
        case shouldDragToPitch = "touchPitch"
        case shouldPinchToRotateAndZoom = "touchZoomRotate"
        case doubleTapShouldZoom = "doubleClickZoom"
        case dragPanIsEnabled = "dragPan"
        case dragRotateIsEnabled = "dragRotate"
        case shouldValidateStyle
        case minimapIsVisible = "minimap"
        case attributionControlIsVisible = "attributionControl"
        case geolocateControlIsVisible = "geolocateControl"
        case navigationControlIsVisible = "navigationControl"
        case projectionControlIsVisible = "projectionControl"
        case scaleControlIsVisible = "scaleControl"
        case terrainControlIsVisible = "terrainControl"
        case space
        case halo
    }
}

extension MTMapOptions {
    package mutating func setLanguage(_ language: MTLanguage) {
        self.language = language
    }

    package mutating func setCenter(_ center: CLLocationCoordinate2D) {
        self.center = center
    }

    package mutating func setBounds(_ bounds: MTBounds) {
        self.bounds = bounds
    }

    package mutating func setProjection(_ projection: MTProjectionType) {
        self.projection = projection
    }

    package mutating func setZoom(_ zoom: Double) {
        self.zoom = zoom
    }

    package mutating func setMaxZoom(_ maxZoom: Double) {
        self.maxZoom = maxZoom
    }

    package mutating func setMinZoom(_ minZoom: Double) {
        self.minZoom = minZoom
    }

    package mutating func setMaxBounds(_ maxBounds: MTBounds?) {
        self.maxBounds = maxBounds
    }

    package mutating func setBearing(_ bearing: Double) {
        self.bearing = bearing
    }

    package mutating func setBearingSnap(_ bearingSnap: Double) {
        self.bearingSnap = bearingSnap
    }

    package mutating func setPitch(_ pitch: Double) {
        self.pitch = pitch
    }

    package mutating func setMaxPitch(_ maxPitch: Double) {
        self.maxPitch = maxPitch
    }

    package mutating func setMinPitch(_ minPitch: Double) {
        self.minPitch = minPitch
    }

    package mutating func setRoll(_ roll: Double) {
        self.roll = roll
    }

    package mutating func setRollIsEnabled(_ rollIsEnabled: Bool) {
        self.rollIsEnabled = rollIsEnabled
    }

    package mutating func setElevation(_ elevation: Double) {
        self.elevation = elevation
    }

    package mutating func setTerrainIsEnabled(_ terrainIsEnabled: Bool) {
        self.terrainIsEnabled = terrainIsEnabled
    }

    package mutating func setTerrainExaggeration(_ terrainExaggeration: Double) {
        self.terrainExaggeration = terrainExaggeration
    }

    package mutating func setCancelPendingTileRequestsWhileZooming(_ cancelPendingTileRequestsWhileZooming: Bool) {
        self.cancelPendingTileRequestsWhileZooming = cancelPendingTileRequestsWhileZooming
    }

    package mutating func setIsCenterClampedToGround(_ isCenterClampedToGround: Bool) {
        self.isCenterClampedToGround = isCenterClampedToGround
    }

    package mutating func setShouldCollectResourceTiming(_ shouldCollectResourceTiming: Bool) {
        self.shouldCollectResourceTiming = shouldCollectResourceTiming
    }

    package mutating func setCrossSourceCollisionsAreEnabled(_ crossSourceCollisionsAreEnabled: Bool) {
        self.crossSourceCollisionsAreEnabled = crossSourceCollisionsAreEnabled
    }

    package mutating func setFadeDuration(_ fadeDuration: Double) {
        self.fadeDuration = fadeDuration
    }

    package mutating func setIsInteractionEnabled(_ isInteractionEnabled: Bool) {
        self.isInteractionEnabled = isInteractionEnabled
    }

    package mutating func setLogoPosition(_ logoPosition: MTMapCorner) {
        self.logoPosition = logoPosition
    }

    package mutating func setMaptilerLogoIsVisible(_ maptilerLogoIsVisible: Bool) {
        self.maptilerLogoIsVisible = maptilerLogoIsVisible
    }

    package mutating func setMaxTileCacheSize(_ maxTileCacheSize: Double) {
        self.maxTileCacheSize = maxTileCacheSize
    }

    package mutating func setMaxTileCacheZoomLevels(_ maxTileCacheZoomLevels: Double) {
        self.maxTileCacheZoomLevels = maxTileCacheZoomLevels
    }

    package mutating func setShouldPitchWithRotate(_ shouldPitchWithRotate: Bool) {
        self.shouldPitchWithRotate = shouldPitchWithRotate
    }

    package mutating func setShouldRefreshExpiredTiles(_ shouldRefreshExpiredTiles: Bool) {
        self.shouldRefreshExpiredTiles = shouldRefreshExpiredTiles
    }

    package mutating func setShouldRenderWorldCopies(_ shouldRenderWorldCopies: Bool) {
        self.shouldRenderWorldCopies = shouldRenderWorldCopies
    }

    package mutating func setShouldDragToPitch(_ shouldDragToPitch: Bool) {
        self.shouldDragToPitch = shouldDragToPitch
    }

    package mutating func setShouldPinchToRotateAndZoom(_ shouldPinchToRotateAndZoom: Bool) {
        self.shouldPinchToRotateAndZoom = shouldPinchToRotateAndZoom
    }

    package mutating func setDoubleTapShouldZoom(_ doubleTapShouldZoom: Bool) {
        self.doubleTapShouldZoom = doubleTapShouldZoom
    }

    package mutating func setDragPanIsEnabled(_ dragPanIsEnabled: Bool) {
        self.dragPanIsEnabled = dragPanIsEnabled
    }

    package mutating func setDragRotateIsEnabled(_ dragRotateIsEnabled: Bool) {
        self.dragRotateIsEnabled = dragRotateIsEnabled
    }

    package mutating func setShouldValidateStyle(_ shouldValidateStyle: Bool) {
        self.shouldValidateStyle = shouldValidateStyle
    }

    package mutating func setSpace(_ space: MTSpaceOption) {
        self.space = space
    }

    package mutating func setHalo(_ halo: MTHaloOption) {
        self.halo = halo
    }

    package mutating func setMinimapIsVisible(_ minimapIsVisible: Bool) {
        self.minimapIsVisible = minimapIsVisible
    }

    package mutating func setAttributionControlIsVisible(_ attributionControlIsVisible: Bool) {
        self.attributionControlIsVisible = attributionControlIsVisible
    }

    package mutating func setGeolocateControlIsVisible(_ geolocateControlIsVisible: Bool) {
        self.geolocateControlIsVisible = geolocateControlIsVisible
    }

    package mutating func setNavigationControlIsVisible(_ navigationControlIsVisible: Bool) {
        self.navigationControlIsVisible = navigationControlIsVisible
    }

    package mutating func setProjectionControlIsVisible(_ projectionControlIsVisible: Bool) {
        self.projectionControlIsVisible = projectionControlIsVisible
    }

    package mutating func setScaleControlIsVisible(_ scaleControlIsVisible: Bool) {
        self.scaleControlIsVisible = scaleControlIsVisible
    }

    package mutating func setTerrainControlIsVisible(_ terrainControlIsVisible: Bool) {
        self.terrainControlIsVisible = terrainControlIsVisible
    }
}
