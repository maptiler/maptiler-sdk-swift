/*
 - This script is designed to be used within WKWebView to interact with the native Swift.
 - It does not use ES Modules or TypeScript to ensure compatibility with non-module environments.
 */

function createTransformRequest(rules) {
    if (!rules || !Array.isArray(rules) || rules.length === 0) return undefined;
    return function(url, resourceType) {
        let finalUrl = url;
        let finalHeaders = undefined;
        let finalCredentials = undefined;

        for (let i = 0; i < rules.length; i++) {
            const rule = rules[i];
            let isMatch = false;
            if (rule.matchType === 'prefix') {
                isMatch = finalUrl.startsWith(rule.matchValue);
            } else if (rule.matchType === 'regex') {
                isMatch = new RegExp(rule.matchValue).test(finalUrl);
            }

            if (isMatch) {
                if (rule.actionType === 'addQueryParameters' && rule.queryParameters) {
                    try {
                        const urlObj = new URL(finalUrl);
                        for (const key in rule.queryParameters) {
                            urlObj.searchParams.set(key, rule.queryParameters[key]);
                        }
                        finalUrl = urlObj.toString();
                    } catch(e) {
                        // ignore
                    }
                } else if (rule.actionType === 'addHeaders' && rule.headers) {
                    finalHeaders = finalHeaders || {};
                    Object.assign(finalHeaders, rule.headers);
                } else if (rule.actionType === 'rewriteURL' && rule.rewriteURL) {
                    finalUrl = finalUrl.replace(
                        rule.matchType === 'regex' ? new RegExp(rule.matchValue) : rule.matchValue,
                        rule.rewriteURL
                    );
                } else if (rule.actionType === 'setCredentials' && rule.credentials) {
                    finalCredentials = rule.credentials;
                }
            }
        }

        const result = { url: finalUrl };
        if (finalHeaders) result.headers = finalHeaders;
        if (finalCredentials) result.credentials = finalCredentials;
        return result;
    };
}

function initializeMap(apiKey, style, options, session, useEuEndpoints) {
    maptilersdk.config.apiKey = apiKey;
    maptilersdk.config.session = session;
    maptilersdk.config.useEuEndpoints = useEuEndpoints === true;

    const baseOptions = {
        container: 'map',
        style: style
    }
    
    const mapOptions = {...baseOptions, ...options}
    if (mapOptions.transformRequest && Array.isArray(mapOptions.transformRequest)) {
        mapOptions.transformRequest = createTransformRequest(mapOptions.transformRequest);
    }
    
    const map = new maptilersdk.Map(mapOptions);

    setUpMapEventsWithLevel(map, options.eventLevel, options.highFrequencyEventThrottleMs);
    window.map = map;
}
