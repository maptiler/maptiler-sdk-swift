import Foundation

// Defines standard MapTiler endpoints and URL constructors for offline assets.
internal enum MTOfflineEndpoints {
    internal static let baseURL = "https://api.maptiler.com"

    // The entry point that defines what sources, sprites, and glyphs need to be downloaded.
    internal static func style(mapId: String, apiKey: String) -> URL? {
        return URL(string: "\(baseURL)/maps/\(mapId)/style.json?key=\(apiKey)")
    }

    // Downloads the sprite assets based on the map ID.
    internal enum Sprites {
        internal static func image(mapId: String, highRes: Bool, apiKey: String) -> URL? {
            let scale = highRes ? "@2x" : ""
            return URL(string: "\(baseURL)/maps/\(mapId)/sprite\(scale).png?key=\(apiKey)")
        }

        internal static func json(mapId: String, highRes: Bool, apiKey: String) -> URL? {
            let scale = highRes ? "@2x" : ""
            return URL(string: "\(baseURL)/maps/\(mapId)/sprite\(scale).json?key=\(apiKey)")
        }
    }

    // Downloads 4 sets of PBF ranges per font stack (0-255, 256-511, 512-767, 768-1023).
    internal enum Glyphs {
        internal static func url(fontStack: String, range: String, apiKey: String) -> URL? {
            // Note: The font stack must be percent-encoded.
            let encodedFontStack = fontStack.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fontStack
            return URL(string: "\(baseURL)/fonts/\(encodedFontStack)/\(range).pbf?key=\(apiKey)")
        }
    }

    // URLs for TileJSON and individual tile templates.
    // Since these are extracted directly from the Style or TileJSON,
    // this helper simply ensures the API key is appended.
    internal enum Tiles {
        internal static func withAPIKey(url: URL, apiKey: String) -> URL {
            return MTURLNormalizer.normalize(url: url, apiKey: apiKey)
        }

        internal static func withAPIKey(urlString: String, apiKey: String) -> URL? {
            guard let url = URL(string: urlString) else { return nil }
            return MTURLNormalizer.normalize(url: url, apiKey: apiKey)
        }
    }
}
