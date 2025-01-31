/*
 - This script is designed to be used within WKWebView to interact with the native Swift.
 - It does not use ES Modules or TypeScript to ensure compatibility with non-module environments.
 */

function initializeMap(apiKey, style, options) {
    maptilersdk.config.apiKey = apiKey;

    const baseOptions = {
        container: 'map',
        style: `https://api.maptiler.com/maps/${style}/style.json?key=${apiKey}`
    }

    const mapOptions = {...baseOptions, ...options}
    const map = new maptilersdk.Map(mapOptions);

    setUpMapEvents(map);
    window.map = map;
}
