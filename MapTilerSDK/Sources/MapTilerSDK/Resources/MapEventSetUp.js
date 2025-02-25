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

    // BRIDGE - Map events propagation

    const events = [
        'boxzoomcancel',
        'boxzoomend',
        'boxzoomstart',
        'click',
        'contextmenu',
        'cooperativegestureprevented',
        'data',
        'dataabort',
        'dataloading',
        'dblclick',
        'drag',
        'dragend',
        'dragstart',
        'idle',
        'load',
        'loadWithTerrain',
        'mousedown',
        'mouseenter',
        'mouseleave',
        'mousemove',
        'mouseout',
        'mouseover',
        'mouseup',
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
        'rotate',
        'rotateend',
        'rotatestart',
        'sourcedata',
        'sourcedataabort',
        'sourcedataloading',
        'styledata',
        'styledataloading',
        'styleimagemissing',
        'terrain',
        'terrainAnimationStart',
        'terrainAnimationStop',
        'touchcancel',
        'touchend',
        'touchmove',
        'touchstart',
        'webglcontextlost',
        'webglcontextrestored',
        'wheel',
        'zoom',
        'zoomend',
        'zoomstart'
    ];

    events.forEach(event => {
        map.on(event, function() {
            window.webkit.messageHandlers.mapHandler.postMessage({
                event: event
            });
        });
    });
}
