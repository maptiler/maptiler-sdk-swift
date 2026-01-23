/*
 - This script is designed to be used within WKWebView to interact with the native Swift.
 - It does not use ES Modules or TypeScript to ensure compatibility with non-module environments.
 */

function setUpMapEvents(map) {
    // Helpers to ensure JSON-safe payloads on iOS 26.2
    function serializeError(err) {
        try {
            return {
                message: String(err && err.message ? err.message : err),
                status: (err && err.status) ? err.status : (err && err.error && err.error.status) ? err.error.status : undefined,
                url: (err && err.url) ? err.url : (err && err.resource && err.resource.url) ? err.resource.url : undefined,
                sourceId: err && err.sourceId ? err.sourceId : undefined
            };
        } catch (_) {
            return { message: 'unknown' };
        }
    }

    function safeSource(src) {
        if (!src) return undefined;
        try {
            return { type: src.type, url: src.url };
        } catch (_) { return undefined; }
    }

    function safeData(e) {
        try {
            return {
                dataType: e.dataType,
                isSourceLoaded: e.isSourceLoaded,
                source: safeSource(e.source),
                sourceDataType: e.sourceDataType,
                // Avoid passing complex/cyclic objects
                coord: e.coord
            };
        } catch (_) { return undefined; }
    }

    // BRIDGE - Error event propagation
    map.on('error', function(error) {
        try {
            window.webkit.messageHandlers.errorHandler.postMessage(
                JSON.stringify({ error: serializeError(error) })
            );
        } catch (_) {}
    });

    // BRIDGE - WebGL event propagation
    map.on('webglcontextlost', function() {
        window.webkit.messageHandlers.errorHandler.postMessage({
            error: 'webglcontextlost'
        });
    });

    // BRIDGE - Map events propagation

    const events = [
        'boxzoomcancel',
        'boxzoomend',
        'boxzoomstart',
        'contextmenu',
        'cooperativegestureprevented',
        'dblclick',
        'idle',
        'load',
        'loadWithTerrain',
        'move',
        'moveend',
        'movestart',
        'pitch',
        'pitchend',
        'pitchstart',
        'projectiontransition',
        'ready',
        'remove',
        'render',
        'resize',
        'terrain',
        'terrainAnimationStart',
        'terrainAnimationStop'
    ];

    events.forEach(event => {
        map.on(event, function() {
            try {
                window.webkit.messageHandlers.mapHandler.postMessage(
                    JSON.stringify({ event: event })
                );
            } catch (_) {}
        });
    });

    // MapTapEvent
    map.on('click', function(e) {
        var data = { lngLat: e.lngLat, point: e.point };
        try {
            window.webkit.messageHandlers.mapHandler.postMessage(
                JSON.stringify({ event: 'click', data: data })
            );
        } catch (_) {}
    });

    // MapImageEvent
    map.on('styleimagemissing', function(e) {
        var data = { id: e.id };
        try {
            window.webkit.messageHandlers.mapHandler.postMessage(
                JSON.stringify({ event: 'styleimagemissing', data: data })
            );
        } catch (_) {}
    });

    // MapDataEvents
    const mapDataEvents = [
        'data',
        'dataabort',
        'dataloading',
        'sourcedata',
        'sourcedataabort',
        'sourcedataloading',
        'styledata',
        'styledataloading',
        'rotate',
        'rotateend',
        'rotatestart'
    ];

    mapDataEvents.forEach(event => {
        map.on(event, function(e) {
            var data = safeData(e);
            try {
                window.webkit.messageHandlers.mapHandler.postMessage(
                    JSON.stringify({ event: event, data: data })
                );
            } catch (_) {}
        });
    });

    // MapTouchEvents
    const mapTouchEvents = [
        'touchcancel',
        'touchend',
        'touchmove',
        'touchstart',
        'drag',
        'dragend',
        'dragstart',
        'zoom',
        'zoomend',
        'zoomstart'
    ];

    mapTouchEvents.forEach(event => {
        map.on(event, function(e) {
            var data = { lngLat: e.lngLat, lngLats: e.lngLats, point: e.point, points: e.points };
            try {
                window.webkit.messageHandlers.mapHandler.postMessage(
                    JSON.stringify({ event: event, data: data })
                );
            } catch (_) {}
        });
    });
}
