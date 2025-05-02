//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTEvent.swift
//  MapTilerSDK
//

/// Events triggered by the SDK
public enum MTEvent: String {
    /// Triggered when the user cancels a "box zoom" interaction,
    /// or when the bounding box does not meet the minimum size threshold.
    case boxZoomDidCancel = "boxzoomcancel"

    /// Triggered when a "box zoom" interaction ends.
    case boxZoomDidEnd = "boxzoomend"

    /// Triggered when a "box zoom" interaction starts.
    case boxZoomDidStart = "boxzoomstart"

    /// Triggered when user taps and releases at the same point on the map.
    case didTap = "click"

    /// Triggered whenever the cooperativeGestures option prevents a gesture from being handled by the map.
    case didPreventCooperativeGesture = "cooperativegestureprevented"

    /// Triggerred when any map data loads or changes.
    case dataDidUpdate = "data"

    /// Triggerred when a request for one of the map's sources' tiles is aborted.
    /// Triggerred when a request for one of the map's sources' data is aborted.
    case dataUpdateDidAbort = "dataabort"

    /// Triggered when any map data (style, source, tile, etc) begins loading or changing asyncronously.
    ///
    /// All dataloading events are followed by a dataDidUpdate, dataUpdateDidAbort or error events.
    case dataLoadingDidStart = "dataloading"

    /// Triggered when a user taps and releases twice at the same point on the map in rapid succession.
    case didDoubleTap = "doubleTapped"

    /// Triggered repeatedly during a "drag to pan" interaction
    case isDragging = "drag"

    /// Triggered when a "drag to pan" interaction ends.
    case dragDidEnd = "dragend"

    /// Triggered when a "drag to pan" interaction starts.
    case dragDidStart = "dragstart"

    /// Triggered after the last frame rendered before the map enters an "idle" state.
    ///
    /// Idle state means that no camera transitions are in progress, all currently requested tiles have loaded,
    /// and all fade/transition animations have completed
    case isIdle = "idle"

    /// Triggered immediately after all necessary resources have been downloaded
    /// and the first visually complete rendering of the map has occurred.
    case didLoad = "load"

    /// Triggered only once in a Map instance lifecycle, when both the load event
    /// and the terrain event with non-null terrain are triggered..
    case didLoadWithTerrain = "loadWithTerrain"

    /// Triggered repeatedly during an animated transition from one view to another,
    /// as the result of either user interaction or methods such as flyTo.
    case isMoving = "move"

    /// Triggered just after the map completes a transition from one view to another,
    /// as the result of either user interaction or methods such as jumpTo.
    case moveDidEnd = "moveend"

    /// Triggered just before the map begins a transition from one view to another,
    /// as the result of either user interaction or methods such as jumpTo.
    case moveDidStart = "movestart"

    /// Triggered repeatedly during the map's pitch (tilt) animation between one state and another
    /// as the result of either user interaction or methods such as flyTo.
    case didUpdatePitch = "pitch"

    /// Triggered immediately after the map's pitch (tilt) finishes changing as the result
    /// of either user interaction or methods such as flyTo.
    case pitchUpdateDidEnd = "pitchend"

    /// Triggered whenever the map's pitch (tilt) begins a change as the result
    /// of either user interaction or methods such as flyTo .
    case pitchUpdateDidStart = "pitchstart"

    /// Triggered when map's projection is modified in other ways than by map being moved.
    case projectionDidModify = "projectiontransition"

    /// Triggered only once after load and wait for all the controls managed by the Map constructor to be dealt with.
    ///
    /// Since the ready event waits that all the basic controls are nicely positioned,
    /// it is safer to use ready than load if you plan to add other custom controls.
    case isReady = "ready"

    /// Triggered immediately after the map has been removed.
    case didRemove = "remove"

    /// Triggered whenever the map is drawn to the screen.
    ///
    /// Drawing occurs with a change to the map's position, zoom, pitch, or bearing,
    /// a change to the map's style,
    /// a change to a GeoJSON source,
    /// or the loading of a vector tile, GeoJSON file, glyph, or sprite.
    case didRender = "render"

    /// Triggered immediately after the map has been resized.
    case didResize = "resize"

    /// Triggered repeatedly during a "drag to rotate" interaction.
    case isRotating = "rotate"

    /// Triggered when a "drag to rotate" interaction ends.
    case rotateDidEnd = "rotateend"

    /// Triggered when a "drag to rotate" interaction starts.
    case rotateDidStart = "rotatestart"

    /// Triggered when one of the map's sources loads or changes,
    /// including if a tile belonging to a source loads or changes.
    case sourceDidUpdate = "sourcedata"

    /// Triggered when a request for one of the map's sources' data is aborted.
    case sourceUpdateDidAbort = "sourcedataabort"

    /// Triggered when one of the map's sources begins loading or changing asyncronously.
    ///
    /// All sourceUpdateDidStart events are followed by a sourceDidUpdate, sourceUpdateDidAbort or error events.
    case sourceUpdateDidStart = "sourcedataloading"

    /// Triggered when the map's style loads or changes.
    case styleDidUpdate = "styledata"

    /// Triggered when the map's style begins loading or changing asyncronously.
    ///
    /// All styleUpdateDidStart events are followed by a styleDidUpdate or error events.
    case styleUpdateDidStart = "styledataloading"

    /// Triggered when an icon or pattern needed by the style is missing.
    case styleImageIsMissing = "styleimagemissing"

    /// Triggered when a terrain event occurs within the map.
    case didTriggerTerrain = "terrain"

    /// The terrainAnimationDidStart event is triggered when the animation begins
    /// transitioning between terrain and non-terrain states.
    case terrainAnimationDidStart = "terrainAnimationStart"

    /// The terrainAnimationDidStop event is triggered when the animation
    /// between terrain and non-terrain states ends.
    case terrainAnimationDidStop = "terrainAnimationStop"

    /// Triggered when a touch is cancelled within the map.
    case touchDidCancel = "touchcancel"

    /// Triggered when a touch ends within the map.
    case touchDidEnd = "touchend"

    /// Triggered when a touch moves within the map.
    case touchDidMove = "touchmove"

    /// Triggered when a touch starts within the map.
    case touchDidStart = "touchstart"

    /// Triggered repeatedly during an animated transition from one zoom level to another,
    /// as the result of either user interaction or methods such as flyTo.
    case isZooming = "zoom"

    /// Triggered just after the map completes a transition from one zoom level to another,
    /// as the result of either user interaction or methods such as flyTo.
    case zoomDidEnd = "zoomend"

    /// Triggered just before the map begins a transition from one zoom level to another,
    /// as the result of either user interaction or methods such as flyTo.
    case zoomDidStart = "zoomstart"
}
