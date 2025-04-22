/*
 - This script is designed to be used within WKWebView to interact with the native Swift.
 - It does not use ES Modules or TypeScript to ensure compatibility with non-module environments.
 */

function setUpMapEvents(map) {
    // BRIDGE - Error event propagation
    map.on('error', function(error) {
        window.webkit.messageHandlers.errorHandler.postMessage({
            error: error
        });
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
            window.webkit.messageHandlers.mapHandler.postMessage({
                event: event
            });
        });
    });

    // MapTapEvent
    map.on('click', function(e) {
        var data = {
            lngLat: e.lngLat,
            point: e.point
        };

        window.webkit.messageHandlers.mapHandler.postMessage({
            event: 'click',
            data: data
        });
    });

    // MapImageEvent
    map.on('styleimagemissing', function(e) {
        var data = {
            id: e.id,
        };

        window.webkit.messageHandlers.mapHandler.postMessage({
            event: 'click',
            data: data
        });
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
            var data = {
                dataType: e.dataType,
                isSourceLoaded: e.isSourceLoaded,
                source: e.source,
                sourceDataType: e.sourceDataType,
                tile: e.tile,
                coord: e.coord
            };

            window.webkit.messageHandlers.mapHandler.postMessage({
                event: event,
                data: data
            });
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
            var data = {
                lngLat: e.lngLat,
                lngLats: e.lngLats,
                point: e.point,
                points: e.points
            };

            window.webkit.messageHandlers.mapHandler.postMessage({
                event: event,
                data: data
            });
        });
    });
}
