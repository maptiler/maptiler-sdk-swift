import Foundation

/// Represents a sprite defined in a map style.
public struct MTStyleSprite: Decodable, Equatable {
    /// The identifier of the sprite. Default is "default" for string-based sprites.
    public let id: String

    /// The URL of the sprite.
    public let url: URL

    public init(id: String = "default", url: URL) {
        self.id = id
        self.url = url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        let urlString = try container.decode(String.self, forKey: .url)
        if let decodedURL = URL(string: urlString) {
            self.url = decodedURL
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .url,
                in: container,
                debugDescription: "Invalid URL string for sprite: \(urlString)"
            )
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case url
    }
}

/// A custom decoder for the `sprite` field in the style JSON, which can be either a single string (URL)
/// or an array of objects containing `id` and `url`.
public enum MTSpriteDecodable: Decodable, Equatable {
    case single(URL)
    case multiple([MTStyleSprite])

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if let stringValue = try? container.decode(String.self) {
                guard let url = URL(string: stringValue) else {
                    throw DecodingError
                        .dataCorruptedError(in: container, debugDescription: "Invalid URL string for sprite.")
                }
                self = .single(url)
                return
            } else if let arrayValue = try? container.decode([MTStyleSprite].self) {
                self = .multiple(arrayValue)
                return
            }
        }

        throw DecodingError.typeMismatch(
            MTSpriteDecodable.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected a string or an array of sprite objects."
            )
        )
    }

    /// Flattens the parsed sprites into a uniform array of `MTStyleSprite`.
    public var sprites: [MTStyleSprite] {
        switch self {
        case .single(let url):
            return [MTStyleSprite(id: "default", url: url)]
        case .multiple(let sprites):
            return sprites
        }
    }
}

/// Represents a tile source extracted from a style JSON.
public struct MTStyleSource: Equatable {
    public let id: String
    public let type: String?
    public let url: String?
    public let tiles: [String]?
    public let minZoom: Int?
    public let maxZoom: Int?

    public init(
        id: String,
        type: String? = nil,
        url: String? = nil,
        tiles: [String]? = nil,
        minZoom: Int? = nil,
        maxZoom: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.url = url
        self.tiles = tiles
        self.minZoom = minZoom
        self.maxZoom = maxZoom
    }
}

/// Represents the non-tile dependencies extracted from a style JSON.
public struct MTStyleDependencies: Equatable {
    /// The sprites required by the style.
    public let sprites: [MTStyleSprite]

    /// The glyphs template URL required by the style.
    public let glyphsTemplate: String?

    /// The tile sources required by the style.
    public let sources: [MTStyleSource]

    /// The unique font stacks required by the style layers.
    public let fontStacks: [[String]]

    public init(
        sprites: [MTStyleSprite],
        glyphsTemplate: String?,
        sources: [MTStyleSource] = [],
        fontStacks: [[String]] = []
    ) {
        self.sprites = sprites
        self.glyphsTemplate = glyphsTemplate
        self.sources = sources
        self.fontStacks = fontStacks
    }
}

/// Internal model used solely for parsing the style JSON.
internal struct MTStyleRoot: Decodable {
    let sprite: MTSpriteDecodable?
    let glyphs: String?
    let sources: [String: MTStyleSourceRaw]?
    let layers: [MTStyleLayerRaw]?

    enum CodingKeys: String, CodingKey {
        case sprite, glyphs, sources, layers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sprite = try container.decodeIfPresent(MTSpriteDecodable.self, forKey: .sprite)
        self.glyphs = try container.decodeIfPresent(String.self, forKey: .glyphs)
        self.sources = try container.decodeIfPresent([String: MTStyleSourceRaw].self, forKey: .sources)
        self.layers = try container.decodeIfPresent([MTStyleLayerRaw].self, forKey: .layers)
    }
}

internal struct MTStyleSourceRaw: Decodable {
    let type: String?
    let url: String?
    let tiles: [String]?
    let minzoom: Double?
    let maxzoom: Double?
}

internal struct MTStyleLayerRaw: Decodable {
    let layout: MTStyleLayerLayoutRaw?
}

internal struct MTStyleLayerLayoutRaw: Decodable {
    let textFont: [String]?

    enum CodingKeys: String, CodingKey {
        case textFont = "text-font"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Safely decode text-font. If it's an expression or something else, it will be nil.
        self.textFont = try? container.decode([String].self, forKey: .textFont)
    }
}

/// A parser responsible for extracting offline dependencies (sprites and glyphs) from a style JSON payload.
public struct MTStyleParser {

    public init() {}

    /// Parses the raw style JSON data to extract non-tile dependencies like sprites and glyphs.
    /// - Parameter data: The raw JSON data of the style.
    /// - Returns: An `MTStyleDependencies` object containing the extracted references.
    /// - Throws: `DecodingError` if the JSON is malformed or required fields are incorrectly formatted.
    public func extractDependencies(from data: Data) throws -> MTStyleDependencies {
        let decoder = JSONDecoder()
        let styleRoot = try decoder.decode(MTStyleRoot.self, from: data)

        let sprites = styleRoot.sprite?.sprites ?? []

        var sources: [MTStyleSource] = []
        if let rawSources = styleRoot.sources {
            for (id, rawSource) in rawSources {
                // Only process vector or raster sources that have either a url or tiles array
                if let type = rawSource.type, type == "vector" || type == "raster" || type == "raster-dem" {
                    if rawSource.url != nil || rawSource.tiles != nil {
                        sources.append(MTStyleSource(
                            id: id,
                            type: type,
                            url: rawSource.url,
                            tiles: rawSource.tiles,
                            minZoom: rawSource.minzoom.map { Int($0) },
                            maxZoom: rawSource.maxzoom.map { Int($0) }
                        ))
                    }
                }
            }
        }

        var uniqueFontStacks: Set<[String]> = []
        if let rawLayers = styleRoot.layers {
            for layer in rawLayers {
                if let font = layer.layout?.textFont {
                    // Simple check to filter out expressions:
                    // If it's an expression, the first element is usually an operator (e.g. "get", "match", etc.)
                    // Static font stacks are typically just an array of font names.
                    if !isExpression(font) {
                        uniqueFontStacks.insert(font)
                    }
                }
            }
        }

        return MTStyleDependencies(
            sprites: sprites,
            glyphsTemplate: styleRoot.glyphs,
            sources: sources,
            fontStacks: Array(uniqueFontStacks)
        )
    }

    private func isExpression(_ fontStack: [String]) -> Bool {
        guard let first = fontStack.first else { return false }

        // A non-exhaustive list of common operators that indicate an expression
        let operators: Set<String> = [
            "get", "has", "at", "in", "match", "case", "step", "interpolate", "coalesce", "let", "var", "literal"
        ]

        return operators.contains(first)
    }
}
