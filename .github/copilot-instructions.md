<!-- AGENT_DIRECTIVES v1 -->

Priority: Follow these directives unless they conflict with system/developer instructions or safety rules.

## System Context

You are an AI agent specialized in Swift and JavaScript development. This document defines mandatory rules for consistent, secure, and maintainable development. Follow the sections below precisely:

- Project Overview
- Pre-Implementation Checklist
- Bridge Rules
- Code Style Guidelines
- SwiftLint Compliance
- Development Best Practices
- Swift Concurrency
- Project Structure
- Style Lifecycle
- Error Handling
- Privacy
- Tests
- Pull Request Template

## Project Overview

This Swift Package wraps the MapTiler JS SDK via a typed Swift↔JS bridge located in `Sources/MapTilerSDK/Bridge`. It renders a web map in `MTMapView` (WKWebView) using `Resources/MapTilerMap.html` which loads `maptiler-sdk.umd.min.js`. Swift APIs translate to JS via `MTCommand`, executed by the bridge. The JS SDK API reference is in `js/docs` (browse `index.html` or search with `rg` or `grep`). Always consult the docs before wrapping any function.`


### Main Components

- UI: `MTMapView` hosts a WKWebView rendering `Resources/MapTilerMap.html`.
- Bridge: Public Swift APIs call `MTCommand`s serialized to JS, executed by `WebViewExecutor`; results decode through `MTBridgeReturnType`.
- Lifecycle: `EventProcessor` listens to JS events, updates `MTMapView` state (`style`, `isInitialized`) and notifies delegates.
- Safety: Mutate map after `didLoad`/`isReady`. Style changes reset layers; `MTStyle` handles queueing.
- Responsibilities: `MTBridge` executes commands; `MTCommand` defines JS to run; `WebViewExecutor` calls `evaluateJavaScript` on WKWebView.

## Pre-Implementation Checklist
  Before writing ANY new code, you MUST:
  - Search for existing related types: `Grep pattern="MT[TypeName]|[RelatedConcept]"`.
  - Read similar existing implementations completely.
  - Identify the established patterns and types used.
  - Confirm no existing types can be reused before creating new ones.
  - Follow SwiftLint rules defined in `.swiftlint.yml` (4-space indentation, trailing newlines, etc.).
  - Run `swiftlint lint --quiet` and fix all violations before concluding work. Skip if swiftlint is not available.
  - Don't proceed until all search/pattern analysis is complete.


## Bridge Rules

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
### Add a new command (checklist)

- Read target JS API in `js/docs` and confirm params/return.
- Create `struct` + internal `Options: Codable` (if needed).
- Implement `toJS()` with a single options object.
- Choose correct `runCommand*` by return type.
- Add `MTMapView` convenience API; validate readiness and inputs.
- Tests: encoding, clamping, and `toJS()` contract.

## Code Style Guidelines (MANDATORY)

- Public entities use the `MT` suffix (e.g., `MTMapView`, `MTMapStyle`). Domain types like `LngLat` are established exceptions.
- Types use PascalCase; variables/functions use camelCase; constants use `let` and camelCase within types/extensions.
- 4-space indentation; default parameters at end of parameter lists.
- End files with exactly one trailing newline.
- Line length: 120 characters max (code and comments). Wrap doc comments accordingly.

## SwiftLint Compliance (MANDATORY)
- ALWAYS follow the rules defined in `.swiftlint.yml` in the root directory.
- Key rules: 4-space indentation, trailing newlines, closure spacing, operator whitespace.
- Test files are excluded from linting but should still follow general style guidelines.
- Before completing implementation, mentally verify compliance with enabled opt-in rules.
- CI/Local requirement: run `swiftlint lint --strict --quiet` and ensure zero warnings/errors. PRs must be lint-clean.

## Development Best Practices

- Prefer `public` for public API; use `open` only when subclassing/overriding by SDK consumers is intended.
- Keep internal implementation non-public using `private`/`fileprivate`. Use `package` where needed across modules.
- New error types must conform to `Error`.
- Document every public declaration with a concise doc comment.
- Aim for sensible unit test coverage; prioritize bridge commands and options.
- Code is linted by SwiftLint using repo rules.
- Each file should have a copyright header.

## Project Structure

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

### Tests

- Tests/MapTilerSDKTests: Unit tests using swift-testing.
    - Helpers: coordinate and color conversions, language decoding.
    - Additional suites: navigation and style tests.

### Swift API Surface (Prefer Stronger Swift Types)
- Prefer expressive Swift-first APIs that hide JS-specific details while encoding the correct JS schema under the hood.
- For values that are strings in JS but have richer Swift domain types (e.g., colors), expose ergonomic initializers and helpers:
- Accept `UIColor`/domain types in public API and convert to the required JS representation (e.g., hex string) internally.
- Keep union models for zoom-dependent values (e.g., “string | ZoomStringValues”) but add Swift-friendly initializers:
  - Constant: `.init(color: UIColor)` or `.init(number: Double)`
  - Zoom stops: `.init(zoomStopsWithColors: [(zoom: Double, color: UIColor)])`, `.init(zoomStops: [(zoom: Double, value: Double)])`
- Use meaningful enums for string unions (e.g., `MTLineCap`, `MTLineJoin`).
- Validate inputs and clamp numeric ranges in Swift before bridging to JS.
- Default parameter values should reflect sensible SDK defaults.

#### Developer-Facing Simplicity (MANDATORY)
- Prefer Swift-first types over raw strings in public APIs (e.g., `UIColor`, enums, typed models).
- Colors (`string | ZoomStringValues`): provide initializers for `.color(UIColor)` and `.zoomStops([(Double, UIColor)])`.
- Numbers (`number | ZoomNumberValues`): provide `.constant(Double)` and `.zoomStops([(Double, Double)])`.
- Mixed unions (`Array<number> | string`, e.g., dash arrays): accept both `[Double]` and `String` forms.
- Add minimal tests to verify encoding and `toJS()` contracts for these conveniences.

### File Organization Rules
- Reusable model types live under `Map/Types` and are grouped by domain:
  - Style-related helpers (e.g., zoom-dependent unions, dash pattern): `Map/Types/Style/`.
  - Geometry and shared primitives: `Map/Types/`.
- Command wrappers live under `Commands/<Area>/<Command>.swift` and include only what pertains to the command:
  - Keep command-specific `Options` with the command file.
  - Move shared/reusable unions and value types to `Map/Types`.
- Public UI/API extensions live under `Map/Extensions/<Area>/MTMapView+<Area>.swift`.
- Tests mirror the structure under `Tests/MapTilerSDKTests/…` to keep intent discoverable.
- One concern per file: avoid placing multiple unrelated general-purpose types alongside a command.

## Swift Concurrency (Swift 6)

- Main thread safety:
  - Mark UI/`MTMapView`-facing APIs and bridge executors as `@MainActor`. Do not access UIKit/WebKit off the main actor.
- Sendability:
  - Add `Sendable` only when a type must be safely shared across concurrency domains. Do not blanket-annotate.
  - Public value-models that are used in async APIs should conform to `Sendable` (and typically `Codable`).
  - Avoid `@unchecked Sendable` unless invariants guarantee thread-safety; document the rationale inline.
- Buildability:
  - Code must compile cleanly under Swift 6 (`// swift-tools-version: 6.0`).
  - Keep non-UI model/tests platform-agnostic when possible; avoid UIKit in Linux-only test contexts.
  - Prefer small, testable units (commands, options) with `toJS()` contract tests over UI-bound tests.

## Style Lifecycle

MUST wait for `didLoad`/`isReady` before mutating style or layers. Changing the reference style resets layers; re-add required sources/layers after `SetStyle`. Prefer batch commands where available. When enabling terrain or projection changes, verify map idleness before subsequent camera moves.

## Error Handling

- Retry once on transient `WKError` bridge failures (excluding unsupported type warnings).
- Return clear, user-facing messages with the failed command and suggested fix.
- Treat unsupported return types as warnings; choose a safer path or request input.

## Privacy

- Never log API keys. Redact sensitive values from structured logs.
- Avoid sending exact user coordinates unless necessary; round or fuzz where acceptable.

## Tests

- Before you make the Pull Request ALWAYS run unit tests to validate the code and fix potential issues. Use the following command to run the tests: xcrun xcodebuild test -scheme MapTilerSDK -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16'
- Add or update unit tests as required (encoding, clamping, `toJS()` contract), but leave execution to the user/CI.
- Prefer small, focused tests near the code you change; avoid introducing unrelated tests.

## Glossary

- `JSString`: A Swift `String` containing JS source to evaluate in the WebView.
- `MTCommand`: A Swift type describing a JS-callable command (`toJS()` returns `JSString`).
- Bridge executor: The component that feeds `JSString` into `evaluateJavaScript`.
- `MTBridgeReturnType`: Decoders for typed return values from JS.

Cross-reference implementation against original prompt requirements before making pull request, and make sure to follow the Pull Request Template below:

## Pull Request Template

[Link to related issue]

## Objective
What is the goal?

## Description
What changed, how and why?

## Acceptance
How were changes tested?

