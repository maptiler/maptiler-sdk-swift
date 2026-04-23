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
}

/// A custom decoder for the `sprite` field in the style JSON, which can be either a single string (URL)
/// or an array of objects containing `id` and `url`.
public enum MTSpriteDecodable: Decodable, Equatable {
    case single(URL)
    case multiple([MTStyleSprite])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            guard let url = URL(string: stringValue) else {
                throw DecodingError
                    .dataCorruptedError(in: container, debugDescription: "Invalid URL string for sprite.")
            }
            self = .single(url)
        } else if let arrayValue = try? container.decode([MTStyleSprite].self) {
            self = .multiple(arrayValue)
        } else {
            throw DecodingError.typeMismatch(
                MTSpriteDecodable.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected a string or an array of sprite objects."
                )
            )
        }
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

/// Represents the non-tile dependencies extracted from a style JSON.
public struct MTStyleDependencies: Equatable {
    /// The sprites required by the style.
    public let sprites: [MTStyleSprite]

    /// The glyphs template URL required by the style.
    public let glyphsTemplate: String?

    public init(sprites: [MTStyleSprite], glyphsTemplate: String?) {
        self.sprites = sprites
        self.glyphsTemplate = glyphsTemplate
    }
}

/// Internal model used solely for parsing the style JSON.
internal struct MTStyleRoot: Decodable {
    let sprite: MTSpriteDecodable?
    let glyphs: String?
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
        return MTStyleDependencies(
            sprites: sprites,
            glyphsTemplate: styleRoot.glyphs
        )
    }
}
