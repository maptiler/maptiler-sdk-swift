/*
 - This script is designed to be used within WKWebView to interact with the native Swift.
 - It does not use ES Modules or TypeScript to ensure compatibility with non-module environments.
 */

function setUpMapEventsWithLevel(map, level, throttleMs) {
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

    // Helper: throttle wrapper
    function throttle(fn, wait) {
        if (!wait || wait <= 0) return fn;
        let last = 0;
        let timeout = null;
        let lastArgs, lastThis;
        const later = () => {
            last = Date.now();
            timeout = null;
            fn.apply(lastThis, lastArgs);
        };
        return function() {
            const now = Date.now();
            const remaining = wait - (now - last);
            lastThis = this; // eslint-disable-line no-invalid-this
            lastArgs = arguments;
            if (remaining <= 0 || remaining > wait) {
                if (timeout) {
                    clearTimeout(timeout);
                    timeout = null;
                }
                later();
            } else if (!timeout) {
                timeout = setTimeout(later, remaining);
            }
        };
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
        try {
            window.webkit.messageHandlers.errorHandler.postMessage({
                error: 'webglcontextlost'
            });
        } catch (_) {}
    });

    const essentialEventsNoData = [
        'idle', 'load', 'loadWithTerrain', 'movestart', 'moveend', 'ready', 'resize', 'remove',
        'boxzoomcancel', 'boxzoomend', 'boxzoomstart',
        'contextmenu', 'cooperativegestureprevented', 'dblclick',
        'projectiontransition',
        'terrain', 'terrainAnimationStart', 'terrainAnimationStop'
    ];

    const dataEvents = [
        'data', 'dataabort', 'dataloading',
        'sourcedata', 'sourcedataabort', 'sourcedataloading',
        'styledata', 'styledataloading'
    ];

    const touchEvents = [
        'touchcancel', 'touchend', 'touchmove', 'touchstart',
        'drag', 'dragend', 'dragstart',
        'zoom', 'zoomend', 'zoomstart',
        'rotate', 'rotateend', 'rotatestart',
        'pitch', 'pitchend', 'pitchstart',
    ];

    const heavyFrameEvents = ['move', 'render'];

    // Register click with data for all levels except 'OFF'
    function registerClick() {
        map.on('click', function(e) {
            var data = { lngLat: e.lngLat, point: e.point };
            try {
                window.webkit.messageHandlers.mapHandler.postMessage(
                    JSON.stringify({ event: 'click', data: data })
                );
            } catch (_) {}
        });
    }

    function registerStyleImageMissing() {
        map.on('styleimagemissing', function(e) {
            var data = { id: e.id };
            try {
                window.webkit.messageHandlers.mapHandler.postMessage(
                    JSON.stringify({ event: 'styleimagemissing', data: data })
                );
            } catch (_) {}
        });
    }

    function registerDataEvents() {
        dataEvents.forEach(event => {
            map.on(event, function(e) {
                var data = safeData(e);
                try {
                    window.webkit.messageHandlers.mapHandler.postMessage(
                        JSON.stringify({ event: event, data: data })
                    );
                } catch (_) {}
            });
        });
    }

    function registerTouchEvents(throttleMs) {
        const throttled = new Set(['touchmove', 'drag', 'zoom', 'rotate', 'pitch']);
        touchEvents.forEach(event => {
            var handler = function(e) {
                var data = { lngLat: e.lngLat, lngLats: e.lngLats, point: e.point, points: e.points };
                try {
                    window.webkit.messageHandlers.mapHandler.postMessage(
                        JSON.stringify({ event: event, data: data })
                    );
                } catch (_) {}
            };

            map.on(event, throttled.has(event) ? throttle(handler, throttleMs || 0) : handler);
        });
    }

    function registerNoDataEvents(list, throttleMs) {
        const throttled = new Set(heavyFrameEvents);
        list.forEach(event => {
            const cb = function() {
                try {
                    window.webkit.messageHandlers.mapHandler.postMessage(
                        JSON.stringify({ event: event })
                    );
                } catch (_) {}
            };
            map.on(event, throttled.has(event) ? throttle(cb, throttleMs || 0) : cb);
        });
    }

    const lvl = (level || 'ESSENTIAL').toUpperCase();
    if (lvl === 'OFF') {
        // Minimal lifecycle: ready/load required for internal orchestration
        registerNoDataEvents(['ready', 'load'], 0);
        return;
    }

    // ESSENTIAL default
    registerNoDataEvents(essentialEventsNoData, 0);
    registerClick();
    registerStyleImageMissing();

    if (lvl === 'CAMERA_ONLY') {
        // Only camera tracking events; avoid wiring full touch/render pipeline.
        registerNoDataEvents(['move', 'zoom'], throttleMs);
        return;
    }

    if (lvl === 'ALL') {
        registerNoDataEvents(heavyFrameEvents, throttleMs);
        registerDataEvents();
        registerTouchEvents(throttleMs);
    }
}
