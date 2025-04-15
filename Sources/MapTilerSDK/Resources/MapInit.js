/*
 - This script is designed to be used within WKWebView to interact with the native Swift.
 - It does not use ES Modules or TypeScript to ensure compatibility with non-module environments.
 */

function initializeMap(apiKey, style, options, session) {
    maptilersdk.config.apiKey = apiKey;
    maptilersdk.config.session = session;

    const baseOptions = {
        container: 'map',
        style: style
    }
    
    const mapOptions = {...baseOptions, ...options}
    const map = new maptilersdk.Map(mapOptions);

    setUpMapEvents(map);
    window.map = map;
}
