<!-- AGENT_DIRECTIVES v1 -->

Priority: Follow these directives unless they conflict with system/developer instructions or safety rules.

## Goals
- Help users manipulate maps (camera, style, data, annotations) via MapTiler SDK Swift.
- Keep UI responsive and safe; never expose secrets; ask clarifying questions when needed.

## Runtime & Lifecycle
- MainActor: Perform all `MTMapView` interactions on the main thread.
- Initialization: Wait for `didLoad`/`isReady` before mutating style or layers.
- Style resets: After `SetStyle`/reference-style changes, re-add needed sources/layers.
- Validate ranges: zoom [0,22], pitch [0,85], bearing [0,360); validate WGS84 lat/lon.

## Tool Allowlist
- navigation: `SetCenter`, `PanBy`, `PanTo`, `JumpTo`, `EaseTo`, `FlyTo`, `SetZoom`, `ZoomIn`, `ZoomOut`, `SetBearing`, `SetPitch`, `SetRoll`, `SetPadding`
- style: `SetStyle`, `GetIdForReferenceStyle`, `GetIdForStyleVariant`, `AddSource`, `RemoveSource`, `SetUrlToSource`, `SetTilesToSource`, `SetDataToSource`, `IsSourceLoaded`, `AddLayer`, `AddLayers`, `RemoveLayer`, `RemoveLayers`, `SetLanguage`, `SetLight`, `SetGlyphs`, `EnableTerrain`, `DisableTerrain`, `EnableGlobeProjection`, `EnableMercatorProjection`
- annotations: `AddMarker`, `AddMarkers`, `RemoveMarker`, `RemoveMarkers`, `AddTextPopup`, `RemoveTextPopup`, `SetCoordinatesToMarker`, `SetCoordinatesToTextPopup`
- gestures: `DragPanEnable/Disable`, `DoubleTapZoomEnable/Disable`, `PinchRotateAndZoomEnable/Disable`, `TwoFingersDragPitchEnable/Disable`
- controls: `AddLogoControl`
- config (restricted): Do not call `SetAPIKey` from agents. Assume app sets it via `MTConfig`.

## Do
- Use idempotent identifiers for sources/layers/annotations; upsert where appropriate.
- Batch operations (`AddMarkers`, `RemoveLayers`) when adding/removing many items.
- Ask for clarification if inputs are ambiguous (e.g., place name without geocoding tool).
- Provide concise user summaries after tool calls (what changed and where).

## Don’t
- Don’t mutate style before it’s loaded or after it changed without re-adding layers.
- Don’t expose or log API keys or precise PII (e.g., exact user location).
- Don’t spam camera updates; throttle or combine when possible.
- Don’t invent data (e.g., POIs) without a tool-backed source.

## Failure Handling
- Retry once on transient bridge errors; otherwise surface a clear summary and next step.
- If a tool is unavailable (e.g., geocoding/routing), ask for coordinates or permission to use external services.
- Treat unsupported return types as warnings and fall back safely or request clarification.

## Privacy
- Redact keys and sensitive fields from logs.
- Round/fuzz user location unless exactness is essential to the request.

## Local JS Reference
- Use `Sources/MapTilerSDK/Resources/maptiler-sdk.umd.min.js(.map)` for offline verification.
- Prefer the source map's `sourcesContent` originals over the minified bundle for semantics.
- Use locally for static reference; avoid network lookups unless explicitly enabled.

## Examples
- "Fly to 47.38, 8.54 at zoom 12" → validate → `FlyTo(center:{lat:47.38,lng:8.54}, animationOptions:{duration:800ms})` → confirm.
- "Switch to satellite and show contours" → `SetStyle(.satellite)` → wait ready → add contours source+line layer → confirm.

## Required Sections (read fully)
- System Context — see section id `system_context`.
- Project Overview — see section id `project_overview`.
- Bridge Rules (how to wrap JS in Swift) — see section id `bridge_rules`.
- Style Lifecycle — see section id `style_lifecycle`.
- Project Structure — see section id `project_structure`.
- Error Handling — see section id `error_handling`.
- Privacy — see section id `privacy_rules`.

## Snippets Index
- BRIDGE_RULES: `<!-- AGENT_SNIPPET:BRIDGE_RULES -->`
- STYLE_LIFECYCLE: `<!-- AGENT_SNIPPET:STYLE_LIFECYCLE -->`
- ERROR_HANDLING: `<!-- AGENT_SNIPPET:ERROR_HANDLING -->`
- PRIVACY_RULES: `<!-- AGENT_SNIPPET:PRIVACY_RULES -->`
- SYSTEM_CONTEXT: `<!-- AGENT_SNIPPET:SYSTEM_CONTEXT -->`
- PROJECT_OVERVIEW: `<!-- AGENT_SNIPPET:PROJECT_OVERVIEW -->`
- PROJECT_STRUCTURE: `<!-- AGENT_SNIPPET:PROJECT_STRUCTURE -->`

<!-- END_AGENT_DIRECTIVES -->

# AGENTS.md AI Agent development rules and project guidelines

<a name="system_context"></a>
## System Context

<!-- AGENT_SNIPPET:SYSTEM_CONTEXT -->

You are an AI agent assisting with modern Swift development, specialized in Swift and JavaScript (TypeScript for typings/reference only). Execution in this SDK occurs in a `WKWebView` using JavaScript. This document defines mandatory rules for consistent, secure and maintainable software development practices.
<!-- END_AGENT_SNIPPET -->

<a name="project_overview"></a>
## Project Overview

<!-- AGENT_SNIPPET:PROJECT_OVERVIEW -->

This repository is a SDK written in Swift, it uses maptiler-sdk.umd.min.js from /Sources/MapTilerSDK/Resources folder and bridges the functions from JS into the Swift. Bridging process is done via code in /Sources/MapTilerSDK/Bridge folder.

- UI: MTMapView hosts a WKWebView rendering Resources/MapTilerMap.html, which loads the MapTiler JS SDK.
- Bridge: Public Swift APIs call Commands which serialize to JS, executed via WebViewExecutor; results decode through MTBridgeReturnType.
- Lifecycle: EventProcessor listens to JS-posted events, updates MTMapView state (style, isInitialized) and notifies delegate blocks.
- Safety: Most map mutations happen after didLoad/isReady; style updates can reset layers—queueing handled within MTStyle.
- Desired functionality from JS is bridged to Swift by creating corresponding MTCommand to it, adding the wrapper in MTMapView extension and exposing the public API for Swift developers.
- MTBridge class is responsible for executing the MTCommand.
- MTCommand is a protocol that defines what JS code is to be executed on the webview executor.
- WebViewExecutor executes the evaluateJavascript on the web view.
- JS used is the MapTiler SDK for JS, and its API reference is found at https://docs.maptiler.com/sdk-js/api/ and if you cannot access it be clear about it so we can provide the necessary context.
<!-- END_AGENT_SNIPPET -->

## Core Principles

- Clarity over brevity (Readable code over shortness of expressions).
- Easy to extend (Decoupled components and separation of concerns).
- Consistency (Easy to memorize API).

## Code style guidelines

- Each public entity is suffixed with MT (i.e. MTMapView, MTMapStyle).
- Classes, Structs, Protocols and Enums use PascalCase (i.e. MTMapOptions, MTMapViewDelegate).
- Variables and Functions use camelCase (i.e. zoomIn(), mapOptions).
- Constants are declared with “let” keyword inside of an Enum, Extension or Struct and should be camelCase.
  
- 4 spaces are used for indentation.
- Function default parameters should be kept at the end of parameters list.
- End files with exactly one trailing newline (no extra blank lines at EOF).

## Development best practices

- Prefer `public` for public API; use `open` only when subclassing/overriding by SDK consumers is intended.
- All internal implementation that we do not want exposed in the API should use private and fileprivate access modifiers.
- Use package modifier for functions and properties that you want to keep private but have accessible in different modules within the package.
- When introducing new error types always conform to Error protocol.
- Write a documentation comment for every public declaration.
- We should aim for high unit test coverage, but be sensible.
- Code will be linted with SwiftLint using rule defined in .swiftlint.yml file in the root of the repo.
- Each file should have a copyright header.

<a name="project_structure"></a>
## Project Structure

<!-- AGENT_SNIPPET:PROJECT_STRUCTURE -->
### Top-Level

- README.md: Usage, features, UIKit/SwiftUI snippets, sources/layers, annotations, installation.
- CHANGELOG.md, CONTRIBUTING.md, LICENSE: Project meta.
- .swiftlint.yml: Lint rules.
- .spi.yml: Swift Package Index config.
- .github/, .githooks/, scripts/: CI, hooks, and scripts scaffolding.

### Library: Sources/MapTilerSDK

- Map/: Core UI and map API.
    - MTMapView: Main UIView backed by WKWebView; exposes map/style APIs, delegates, and lifecycle (didLoad, isReady, isIdle).
    - MTMapViewContainer: SwiftUI wrapper.
    - MTMapOptions + Options/: Camera, padding, animation, gestures config.
    - Style/: MTStyle, reference styles/variants, glyphs/terrain/tile scheme, style errors.
    - Gestures/: Gesture types and services (pan, pinch/rotate/zoom, double tap).
    - Types/: Shared types (e.g., LngLat, MTColor, MTPoint, MTLight, source data).
    - Extensions/: Glue to the bridge/delegate protocols.
- Bridge/: Swift ↔️ JS bridge via WebView.
    - MTCommand: Protocol for JS-callable commands.
    - MTBridge: Executes commands via an executor.
    - WebViewExecutor: WKWebView evaluator; error handling, verbose logging.
    - WebViewManager: WebView setup, script messaging, navigation delegate.
    - MTBridgeReturnType, MTError: Typed return decoding and error surface.
- Commands/: Strongly-typed wrappers that turn Swift calls into JS invocations.
    - Config/: API key, telemetry, units, caching, session logic.
    - Navigation/: Camera controls (flyTo, easeTo, jumpTo, pan/zoom/bearing/pitch/roll, bounds, padding).
    - Style/: Add/remove sources and layers, set style, language, light, glyphs, projection, terrain.
    - Annotations/: Add/remove markers and text popups, set coordinates, batch ops.
    - Gestures/: Enable/disable gesture types.
    - Controls/: Add logo control.
- Annotations/: Public annotation APIs (MTMarker, MTTextPopup, MTCustomAnnotationView, base MTAnnotation).
- Events/: Event pipeline (EventProcessor, buffer) that feeds MTMapViewDelegate and content delegates.
- Helpers/: Codable helpers, color/coordinates converters, benchmarking.
- Logging/: Log level/types and adapters (MTLogger, OSLogger).
- Root files: MTConfig (API key, session logic, log level), MTEvent, MTLanguage, MTLocationManager, MTUnit.
- Resources/: Embedded assets for the web map container.
    - MapTilerMap.html: Base HTML container.
    - MapInit.js, MapEventSetUp.js: Map bootstrapping and event wiring.
    - maptiler-sdk.umd.min.js(.map), maptiler-sdk.css: MapTiler JS SDK bundle and styles.

<a name="bridge_rules"></a>
## Bridge Rules

<!-- AGENT_SNIPPET:BRIDGE_RULES -->
MUST follow this end-to-end flow when wrapping a JS API into Swift:

1) Discover and design
- Read the JS API in MapTiler SDK for JS docs; determine parameters, defaults, and return type.
- Define a Swift `struct` conforming to `MTCommand` with strongly typed, Codable parameters.

2) Encode parameters
- Use existing Codable helpers to build a compact JSON payload; avoid manual string concat where possible.
- Validate/clamp numeric ranges in Swift prior to execution (zoom, pitch, bearing, durations).

3) Implement `toJS()`
- Build a `JSString` that calls the JS API. Prefer passing a single options JSON object.
- If easing functions or callbacks are needed, convert to a JS expression string (see existing commands for `easing.toJS()`).

4) Choose execution path and return type
- For commands with no meaningful return: `runCommand(_:)`.
- For numeric result: `runCommandWithDoubleReturnValue(_:)`.
- For boolean: `runCommandWithBoolReturnValue(_:)`.
- For string: `runCommandWithStringReturnValue(_:)`.
- For coordinates: `runCommandWithCoordinateReturnValue(_:)`.
- If a new return type is required, extend `MTBridgeReturnType` in a focused change.

5) Public API surface
- Add a thin convenience method on `MTMapView` (or a relevant extension) that:
  - Ensures the map/style are ready (`didLoad`/`isReady`).
  - Validates inputs and applies sensible defaults.
  - Calls the bridge using the appropriate `runCommand*` helper.
  - Surfaces a completion with `Result<…, MTError>` or `async` variant.

6) Threading and lifecycle
- MUST run on the main thread when touching `MTMapView` or UIKit.
- Avoid firing commands before the WebView/bridge is available; prefer queuing until ready.

7) Testing
- Unit test: parameter encoding and range clamping.
- Contract test: `toJS()` shape for simple cases (e.g., duration only).

Example skeleton:

```swift
package struct RotateTo: MTCommand {
    var bearing: Double
    var durationMs: Double?

    package func toJS() -> JSString {
        struct Options: Codable { let bearing: Double; let duration: Double? }
        let opts = Options(bearing: bearing, duration: durationMs)
        let json = opts.toJSON() ?? "{}"
        return "\(MTBridge.mapObject).rotateTo(\(json));"
    }
}

public extension MTMapView {
    func setBearing(_ bearing: Double, durationMs: Double? = nil, completion: ((Result<Void, MTError>) -> Void)? = nil) {
        let clamped = (bearing.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        runCommand(RotateTo(bearing: clamped, durationMs: durationMs), completion: completion)
    }
}
```
<!-- END_AGENT_SNIPPET -->

<a name="style_lifecycle"></a>
## Style Lifecycle

<!-- AGENT_SNIPPET:STYLE_LIFECYCLE -->
MUST wait for `didLoad`/`isReady` before mutating style or layers. Changing the reference style resets layers; re-add required sources/layers after `SetStyle`. Prefer batch commands where available. When enabling terrain or projection changes, verify map idleness before subsequent camera moves.
<!-- END_AGENT_SNIPPET -->

<a name="error_handling"></a>
## Error Handling

<!-- AGENT_SNIPPET:ERROR_HANDLING -->
- Retry once on transient `WKError` bridge failures (excluding unsupported type warnings).
- Return clear, user-facing messages with the failed command and suggested fix.
- Treat unsupported return types as warnings; choose a safer path or request input.
<!-- END_AGENT_SNIPPET -->

<a name="privacy_rules"></a>
## Privacy

<!-- AGENT_SNIPPET:PRIVACY_RULES -->
- Never log API keys. Redact sensitive values from structured logs.
- Avoid sending exact user coordinates unless necessary; round or fuzz where acceptable.
<!-- END_AGENT_SNIPPET -->

### Examples

- Standalone SwiftUI/UIKit samples: BasicMapView+SwiftUI.swift, BasicMapViewController+UIKit.swift, MarkersAndPopups+…, SourcesAndLayers+….
- MapTilerMobileDemo/: Full UIKit demo Xcode project with storyboards, controls, custom views, sample GeoJSON.
- Assets: Logo, marker, screenshots.

### Tests

- Tests/MapTilerSDKTests: Unit tests using swift-testing.
    - Helpers: coordinate and color conversions, language decoding.
    - Additional suites: navigation and style tests.

<!-- END_AGENT_SNIPPET -->


## Pull Request Template

[Link to related issue]

## Objective
What is the goal?

## Description
What changed, how and why?

## Acceptance
How were changes tested?
