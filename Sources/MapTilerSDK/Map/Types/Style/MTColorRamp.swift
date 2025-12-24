//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTColorRamp.swift
//  MapTilerSDK
//

import Foundation
import UIKit

/// RGBA color represented by 0...255 components.
public struct MTRGBAColor: Sendable, Codable {
    public var red: Int
    public var green: Int
    public var blue: Int
    public var alpha: Int?

    /// Initializes the color with individual components.
    public init(red: Int, green: Int, blue: Int, alpha: Int? = nil) {
        self.red = MTRGBAColor.clamp(red)
        self.green = MTRGBAColor.clamp(green)
        self.blue = MTRGBAColor.clamp(blue)
        self.alpha = alpha.map(MTRGBAColor.clamp)
    }

    /// Initializes the color from `UIColor`, preserving alpha.
    public init(color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        self.red = MTRGBAColor.clamp(Int(round(red * 255)))
        self.green = MTRGBAColor.clamp(Int(round(green * 255)))
        self.blue = MTRGBAColor.clamp(Int(round(blue * 255)))
        let resolvedAlpha = Int(round(alpha * 255))
        self.alpha = resolvedAlpha == 255 ? nil : MTRGBAColor.clamp(resolvedAlpha)
    }

    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let red = try container.decode(Double.self)
        let green = try container.decode(Double.self)
        let blue = try container.decode(Double.self)
        let alpha = try container.decodeIfPresent(Double.self)

        self.red = MTRGBAColor.clamp(Int(round(red)))
        self.green = MTRGBAColor.clamp(Int(round(green)))
        self.blue = MTRGBAColor.clamp(Int(round(blue)))
        self.alpha = alpha.map { MTRGBAColor.clamp(Int(round($0))) }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(red)
        try container.encode(green)
        try container.encode(blue)

        if let alpha {
            try container.encode(alpha)
        }
    }

    package var components: [Int] {
        var values = [red, green, blue]

        if let alpha {
            values.append(alpha)
        }

        return values
    }

    private static func clamp(_ value: Int) -> Int {
        return max(0, min(255, value))
    }
}

/// A stop describing the value and color to apply.
public struct MTColorRampStop: Sendable, Codable {
    public var value: Double
    public var color: MTRGBAColor

    public init(value: Double, color: MTRGBAColor) {
        self.value = value
        self.color = color
    }
}

/// Bounds of a color ramp.
public struct MTColorRampBounds: Sendable, Codable {
    public let min: Double
    public let max: Double
}

/// Resampling methods supported by MapTiler SDK.
public enum MTColorRampResampleMethod: String, Sendable, Codable, CaseIterable {
    case easeInSquare = "ease-in-square"
    case easeOutSquare = "ease-out-square"
    case easeInSqrt = "ease-in-sqrt"
    case easeOutSqrt = "ease-out-sqrt"
    case easeInExp = "ease-in-exp"
    case easeOutExp = "ease-out-exp"
}

/// Built-in presets shipped with the SDK.
public enum MTColorRampPreset: String, Sendable, Codable, CaseIterable {
    case null = "NULL"
    case gray = "GRAY"
    case jet = "JET"
    case hsv = "HSV"
    case hot = "HOT"
    case spring = "SPRING"
    case summer = "SUMMER"
    case automn = "AUTOMN"
    case winter = "WINTER"
    case bone = "BONE"
    case copper = "COPPER"
    case greys = "GREYS"
    case yignbu = "YIGNBU"
    case greens = "GREENS"
    case yiorrd = "YIORRD"
    case bluered = "BLUERED"
    case rdbu = "RDBU"
    case picnic = "PICNIC"
    case rainbow = "RAINBOW"
    case portland = "PORTLAND"
    case blackbody = "BLACKBODY"
    case earth = "EARTH"
    case electric = "ELECTRIC"
    case viridis = "VIRIDIS"
    case inferno = "INFERNO"
    case magma = "MAGMA"
    case plasma = "PLASMA"
    case warm = "WARM"
    case cool = "COOL"
    case rainbowSoft = "RAINBOW_SOFT"
    case bathymetry = "BATHYMETRY"
    case cdom = "CDOM"
    case chlorophyll = "CHLOROPHYLL"
    case density = "DENSITY"
    case freesurfaceBlue = "FREESURFACE_BLUE"
    case freesurfaceRed = "FREESURFACE_RED"
    case oxygen = "OXYGEN"
    case par = "PAR"
    case phase = "PHASE"
    case salinity = "SALINITY"
    case temperature = "TEMPERATURE"
    case turbidity = "TURBIDITY"
    case velocityBlue = "VELOCITY_BLUE"
    case velocityGreen = "VELOCITY_GREEN"
    case cubehelix = "CUBEHELIX"
    case cividis = "CIVIDIS"
    case turbo = "TURBO"
    case rocket = "ROCKET"
    case mako = "MAKO"
}

/// Options used when instantiating a color ramp.
public struct MTColorRampOptions: Sendable, Codable {
    public var min: Double?
    public var max: Double?
    public var stops: [MTColorRampStop]

    public init(min: Double? = nil, max: Double? = nil, stops: [MTColorRampStop]) {
        self.min = min
        self.max = max
        self.stops = stops
    }
}

/// Options for rendering the ramp to a canvas strip.
public struct MTColorRampCanvasStripOptions: Sendable, Codable {
    public var horizontal: Bool?
    public var size: Int?
    public var smooth: Bool?

    public init(horizontal: Bool? = nil, size: Int? = nil, smooth: Bool? = nil) {
        self.horizontal = horizontal
        self.size = size
        self.smooth = smooth
    }
}

/// Array-based stop definition for `fromArrayDefinition`.
public struct MTColorRampArrayStop: Sendable, Codable {
    public var value: Double
    public var color: MTRGBAColor

    public init(value: Double, color: MTRGBAColor) {
        self.value = value
        self.color = color
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(value)
        try container.encode(color)
    }
}

/// Swift wrapper over the MapTiler SDK ColorRamp class.
@MainActor
public final class MTColorRamp: @unchecked Sendable {
    private enum Creation {
        case custom(MTColorRampOptions)
        case preset(MTColorRampPreset)
        case arrayDefinition([MTColorRampArrayStop])
    }

    public let identifier: String
    private var creation: Creation

    /// Creates a custom color ramp using the provided options.
    public convenience init(options: MTColorRampOptions) {
        self.init(identifier: MTColorRamp.makeIdentifier(), creation: .custom(options))
    }

    /// Creates a custom color ramp using explicit values and stops.
    public convenience init(min: Double? = nil, max: Double? = nil, stops: [MTColorRampStop]) {
        let options = MTColorRampOptions(min: min, max: max, stops: stops)
        self.init(options: options)
    }

    /// Creates a color ramp from a built-in preset. The preset is cloned to keep the global preset untouched.
    public static func preset(_ preset: MTColorRampPreset) -> MTColorRamp {
        return MTColorRamp(identifier: MTColorRamp.makeIdentifier(), creation: .preset(preset))
    }

    /// Creates a color ramp from the array definition.
    public static func fromArrayDefinition(_ definition: [MTColorRampArrayStop]) -> MTColorRamp {
        return MTColorRamp(identifier: MTColorRamp.makeIdentifier(), creation: .arrayDefinition(definition))
    }

    private init(identifier: String, creation: Creation) {
        self.identifier = identifier
        self.creation = creation
    }
}

public extension MTColorRamp {
    /// Returns bounds of the color ramp.
    public func getBounds(in mapView: MTMapView) async throws -> MTColorRampBounds {
        try await ensureInitialized(in: mapView)
        let result = try await mapView.bridge.execute(GetColorRampBounds(identifier: identifier))

        guard case .string(let json) = result else {
            throw MTError.unsupportedReturnType(description: "Expected bounds JSON, got \(String(describing: result)).")
        }

        guard let data = json.data(using: .utf8) else {
            throw MTError.invalidResultType(description: "Failed to encode bounds to UTF-8.")
        }

        return try JSONDecoder().decode(MTColorRampBounds.self, from: data)
    }

    /// Returns the color at the provided value.
    public func getColor(
        at value: Double,
        smooth: Bool = true,
        in mapView: MTMapView
    ) async throws -> MTRGBAColor {
        try await ensureInitialized(in: mapView)
        let options = smooth ? #"{"smooth":true}"# : #"{"smooth":false}"#
        let result = try await mapView.bridge.execute(
            GetColorFromColorRamp(identifier: identifier, value: value, optionsJSON: options)
        )

        return try MTColorRamp.decodeColor(from: result)
    }

    /// Returns the color hex string at the provided value.
    public func getColorHex(
        at value: Double,
        smooth: Bool = true,
        includeAlpha: Bool = false,
        in mapView: MTMapView
    ) async throws -> String {
        try await ensureInitialized(in: mapView)
        let options = """
        {
            "smooth": \(smooth ? "true" : "false"),
            "withAlpha": \(includeAlpha ? "true" : "false")
        }
        """
        let result = try await mapView.bridge.execute(
            GetColorHexFromColorRamp(identifier: identifier, value: value, optionsJSON: options)
        )

        guard case .string(let hex) = result else {
            throw MTError.unsupportedReturnType(description: "Expected hex string, got \(String(describing: result)).")
        }

        return hex
    }

    /// Returns the color for a relative value in [0, 1].
    public func getColorRelative(
        at value: Double,
        smooth: Bool = true,
        in mapView: MTMapView
    ) async throws -> MTRGBAColor {
        try await ensureInitialized(in: mapView)
        let options = smooth ? #"{"smooth":true}"# : #"{"smooth":false}"#
        let result = try await mapView.bridge.execute(
            GetColorRelativeFromColorRamp(identifier: identifier, value: value, optionsJSON: options)
        )

        return try MTColorRamp.decodeColor(from: result)
    }

    /// Returns raw stops backing the ramp.
    public func getRawColorStops(in mapView: MTMapView) async throws -> [MTColorRampStop] {
        try await ensureInitialized(in: mapView)
        let result = try await mapView.bridge.execute(GetRawColorStopsFromColorRamp(identifier: identifier))

        guard case .string(let json) = result, let data = json.data(using: .utf8) else {
            let description = "Expected color stops JSON, got \(String(describing: result))."
            throw MTError.unsupportedReturnType(description: description)
        }

        return try JSONDecoder().decode([MTColorRampStop].self, from: data)
    }

    /// Clones the color ramp.
    public func clone(in mapView: MTMapView) async throws -> MTColorRamp {
        try await ensureInitialized(in: mapView)
        let targetIdentifier = MTColorRamp.makeIdentifier()
        let result = try await mapView.bridge.execute(
            CloneColorRamp(sourceIdentifier: identifier, targetIdentifier: targetIdentifier)
        )

        guard case .string = result else {
            let description = "Expected new identifier, got \(String(describing: result))."
            throw MTError.unsupportedReturnType(description: description)
        }

        let options = try await snapshotOptions(for: targetIdentifier, in: mapView)
        return MTColorRamp(identifier: targetIdentifier, creation: .custom(options))
    }

    /// Returns a ramp reversed in-place or cloned depending on the `clone` flag.
    public func reverse(clone: Bool = true, in mapView: MTMapView) async throws -> MTColorRamp {
        try await ensureInitialized(in: mapView)
        let targetIdentifier = clone ? MTColorRamp.makeIdentifier() : identifier
        let result = try await mapView.bridge.execute(
            ReverseColorRamp(sourceIdentifier: identifier, targetIdentifier: targetIdentifier, clone: clone)
        )

        guard case .string = result else {
            let description = "Expected identifier after reverse, got \(String(describing: result))."
            throw MTError.unsupportedReturnType(description: description)
        }

        let options = try await snapshotOptions(for: targetIdentifier, in: mapView)

        if clone {
            return MTColorRamp(identifier: targetIdentifier, creation: .custom(options))
        } else {
            creation = .custom(options)
            return self
        }
    }

    /// Scales the ramp to the given bounds.
    public func scale(
        min: Double,
        max: Double,
        clone: Bool = true,
        in mapView: MTMapView
    ) async throws -> MTColorRamp {
        try await ensureInitialized(in: mapView)
        let targetIdentifier = clone ? MTColorRamp.makeIdentifier() : identifier
        let clampedMin = min
        let clampedMax = max == min ? min + 1 : max

        let result = try await mapView.bridge.execute(
            ScaleColorRamp(
                sourceIdentifier: identifier,
                targetIdentifier: targetIdentifier,
                min: clampedMin,
                max: clampedMax,
                clone: clone
            )
        )

        guard case .string = result else {
            let description = "Expected identifier after scale, got \(String(describing: result))."
            throw MTError.unsupportedReturnType(description: description)
        }

        let options = try await snapshotOptions(for: targetIdentifier, in: mapView)

        if clone {
            return MTColorRamp(identifier: targetIdentifier, creation: .custom(options))
        } else {
            creation = .custom(options)
            return self
        }
    }

    /// Replaces the stops on the ramp.
    public func setStops(
        _ stops: [MTColorRampStop],
        clone: Bool = true,
        in mapView: MTMapView
    ) async throws -> MTColorRamp {
        try await ensureInitialized(in: mapView)
        let targetIdentifier = clone ? MTColorRamp.makeIdentifier() : identifier
        let encodedStops = try MTColorRamp.encodeToJSONString(stops)

        let result = try await mapView.bridge.execute(
            SetStopsOnColorRamp(
                sourceIdentifier: identifier,
                targetIdentifier: targetIdentifier,
                stopsJSON: encodedStops,
                clone: clone
            )
        )

        guard case .string = result else {
            let description = "Expected identifier after setStops, got \(String(describing: result))."
            throw MTError.unsupportedReturnType(description: description)
        }

        let sortedStops = stops.sorted { $0.value < $1.value }
        let options = MTColorRampOptions(
            min: sortedStops.first?.value,
            max: sortedStops.last?.value,
            stops: sortedStops
        )

        if clone {
            return MTColorRamp(identifier: targetIdentifier, creation: .custom(options))
        } else {
            creation = .custom(options)
            return self
        }
    }

    /// Resamples the ramp using the provided method and sample count.
    public func resample(
        _ method: MTColorRampResampleMethod,
        samples: Int = 15,
        in mapView: MTMapView
    ) async throws -> MTColorRamp {
        try await ensureInitialized(in: mapView)
        let targetIdentifier = MTColorRamp.makeIdentifier()
        let safeSamples = max(2, samples)

        let result = try await mapView.bridge.execute(
            ResampleColorRamp(
                sourceIdentifier: identifier,
                targetIdentifier: targetIdentifier,
                method: method.rawValue,
                samples: safeSamples
            )
        )

        guard case .string = result else {
            let description = "Expected identifier after resample, got \(String(describing: result))."
            throw MTError.unsupportedReturnType(description: description)
        }

        let options = try await snapshotOptions(for: targetIdentifier, in: mapView)
        return MTColorRamp(identifier: targetIdentifier, creation: .custom(options))
    }

    /// Prepends a transparent stop at the beginning of the ramp.
    public func transparentStart(in mapView: MTMapView) async throws -> MTColorRamp {
        try await ensureInitialized(in: mapView)
        let targetIdentifier = MTColorRamp.makeIdentifier()
        let result = try await mapView.bridge.execute(
            TransparentStartColorRamp(sourceIdentifier: identifier, targetIdentifier: targetIdentifier)
        )

        guard case .string = result else {
            let description = "Expected identifier after transparentStart, got \(String(describing: result))."
            throw MTError.unsupportedReturnType(description: description)
        }

        let options = try await snapshotOptions(for: targetIdentifier, in: mapView)
        return MTColorRamp(identifier: targetIdentifier, creation: .custom(options))
    }

    /// Returns true if the first stop is transparent.
    public func hasTransparentStart(in mapView: MTMapView) async throws -> Bool {
        try await ensureInitialized(in: mapView)
        let result = try await mapView.bridge.execute(
            HasTransparentStartColorRamp(identifier: identifier)
        )

        guard case .bool(let value) = result else {
            throw MTError.unsupportedReturnType(
                description: "Expected boolean for hasTransparentStart, got \(String(describing: result))."
            )
        }

        return value
    }

    /// Renders the ramp to a canvas strip and returns it as `UIImage`.
    public func getCanvasStrip(
        options: MTColorRampCanvasStripOptions = MTColorRampCanvasStripOptions(),
        in mapView: MTMapView
    ) async throws -> UIImage {
        try await ensureInitialized(in: mapView)
        let clampedSize = options.size.map { max(1, min(2048, $0)) }
        let sanitizedOptions = MTColorRampCanvasStripOptions(
            horizontal: options.horizontal,
            size: clampedSize,
            smooth: options.smooth
        )

        let optionsJSON = try MTColorRamp.encodeToJSONString(sanitizedOptions)
        let result = try await mapView.bridge.execute(
            GetCanvasStripFromColorRamp(identifier: identifier, optionsJSON: optionsJSON)
        )

        guard case .string(let dataURL) = result else {
            throw MTError.unsupportedReturnType(description: "Expected data URL for canvas strip.")
        }

        guard let base64 = dataURL.split(separator: ",").last,
            let data = Data(base64Encoded: String(base64)),
            let image = UIImage(data: data) else {
            throw MTError.invalidResultType(description: "Failed to decode canvas strip data.")
        }

        return image
    }

}

public extension MTColorRamp {
    /// Deprecated completion-based variant of `getColor(at:smooth:in:)`.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func getColor(
        at value: Double,
        smooth: Bool = true,
        in mapView: MTMapView,
        completionHandler: ((Result<MTRGBAColor, MTError>) -> Void)? = nil
    ) {
        executeWithCompletion(
            { try await self.getColor(at: value, smooth: smooth, in: mapView) },
            completion: completionHandler
        )
    }

    /// Deprecated completion-based variant of `getColorHex(at:smooth:includeAlpha:in:)`.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func getColorHex(
        at value: Double,
        smooth: Bool = true,
        includeAlpha: Bool = false,
        in mapView: MTMapView,
        completionHandler: ((Result<String, MTError>) -> Void)? = nil
    ) {
        executeWithCompletion(
            { try await self.getColorHex(at: value, smooth: smooth, includeAlpha: includeAlpha, in: mapView) },
            completion: completionHandler
        )
    }

    /// Deprecated completion-based variant of `getBounds(in:)`.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func getBounds(
        in mapView: MTMapView,
        completionHandler: ((Result<MTColorRampBounds, MTError>) -> Void)? = nil
    ) {
        executeWithCompletion({ try await self.getBounds(in: mapView) }, completion: completionHandler)
    }

    /// Deprecated completion-based variant of `getRawColorStops(in:)`.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func getRawColorStops(
        in mapView: MTMapView,
        completionHandler: ((Result<[MTColorRampStop], MTError>) -> Void)? = nil
    ) {
        executeWithCompletion({ try await self.getRawColorStops(in: mapView) }, completion: completionHandler)
    }

    /// Deprecated completion-based variant of `clone(in:)`.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    func clone(
        in mapView: MTMapView,
        completionHandler: ((Result<MTColorRamp, MTError>) -> Void)? = nil
    ) {
        executeWithCompletion({ try await self.clone(in: mapView) }, completion: completionHandler)
    }
}

private extension MTColorRamp {
    func ensureInitialized(in mapView: MTMapView) async throws {
        switch creation {
        case .custom(let options):
            let json = try MTColorRamp.encodeToJSONString(options)
            try await mapView.bridge.execute(CreateColorRamp(identifier: identifier, optionsJSON: json))
        case .preset(let preset):
            try await mapView.bridge.execute(
                CreateColorRampFromPreset(identifier: identifier, preset: preset.rawValue)
            )
        case .arrayDefinition(let definition):
            let json = try MTColorRamp.encodeToJSONString(definition)
            try await mapView.bridge.execute(
                CreateColorRampFromArrayDefinition(identifier: identifier, definitionJSON: json)
            )
        }
    }

    func snapshotOptions(for identifier: String, in mapView: MTMapView) async throws -> MTColorRampOptions {
        let stops = try await MTColorRamp.decodeStops(from: identifier, in: mapView)
        let minValue = stops.min { $0.value < $1.value }?.value
        let maxValue = stops.max { $0.value < $1.value }?.value
        return MTColorRampOptions(min: minValue, max: maxValue, stops: stops)
    }

    static func decodeColor(from result: MTBridgeReturnType?) throws -> MTRGBAColor {
        guard case .string(let json) = result, let data = json.data(using: .utf8) else {
            throw MTError.unsupportedReturnType(description: "Expected color JSON, got \(String(describing: result)).")
        }

        let components = try JSONDecoder().decode([Int].self, from: data)

        guard (3...4).contains(components.count) else {
            throw MTError.invalidResultType(description: "Expected 3 or 4 color components.")
        }

        let alpha = components.count == 4 ? components[3] : nil
        return MTRGBAColor(red: components[0], green: components[1], blue: components[2], alpha: alpha)
    }

    static func decodeStops(from identifier: String, in mapView: MTMapView) async throws -> [MTColorRampStop] {
        let result = try await mapView.bridge.execute(GetRawColorStopsFromColorRamp(identifier: identifier))

        guard case .string(let json) = result, let data = json.data(using: .utf8) else {
            let description = "Expected color stops JSON, got \(String(describing: result))."
            throw MTError.unsupportedReturnType(description: description)
        }

        return try JSONDecoder().decode([MTColorRampStop].self, from: data)
    }

    static func encodeToJSONString<T: Encodable>(_ value: T) throws -> String {
        guard let json = value.toJSON() else {
            throw MTError.invalidResultType(description: "Failed to encode \(T.self) to JSON.")
        }

        return json
    }

    func executeWithCompletion<T>(
        _ operation: @escaping () async throws -> T,
        completion: ((Result<T, MTError>) -> Void)?
    ) {
        guard let completion else {
            return
        }

        Task {
            do {
                completion(.success(try await operation()))
            } catch let error as MTError {
                completion(.failure(error))
            } catch {
                completion(.failure(.unknown(description: "\(error)")))
            }
        }
    }

    static func makeIdentifier() -> String {
        return "colorRamp\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
    }
}
