import Foundation

// Centralizes path resolution for offline packs.
internal enum MTOfflineStoragePaths {

    // The root offline directory: `Documents/MTOffline/`
    internal static var rootDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("MTOffline", isDirectory: true)
    }

    // The root directory for a specific offline pack: `Documents/MTOffline/<packID>/`
    internal static func packDirectory(for packID: String) -> URL {
        return rootDirectory.appendingPathComponent(packID, isDirectory: true)
    }

    // The style file path for a specific pack: `Documents/MTOffline/<packID>/style.json`
    internal static func styleURL(for packID: String) -> URL {
        return packDirectory(for: packID).appendingPathComponent("style.json", isDirectory: false)
    }

    // The sprite file path for a specific pack.
    // Example paths: `Documents/MTOffline/<packID>/sprite.png` or `Documents/MTOffline/<packID>/sprite@2x.json`
    internal static func spriteURL(for packID: String, scale: Int = 1, isJSON: Bool = false) -> URL {
        let suffix = scale > 1 ? "@\(scale)x" : ""
        let extensionName = isJSON ? "json" : "png"
        let fileName = "sprite\(suffix).\(extensionName)"
        return packDirectory(for: packID).appendingPathComponent(fileName, isDirectory: false)
    }

    // The glyph path for a specific pack, font stack, and range:
    // `Documents/MTOffline/<packID>/glyphs/<fontstack>/<range>.pbf`
    internal static func glyphsURL(for packID: String, fontStack: String, range: String) -> URL {
        return packDirectory(for: packID)
            .appendingPathComponent("glyphs", isDirectory: true)
            .appendingPathComponent(fontStack, isDirectory: true)
            .appendingPathComponent("\(range).pbf", isDirectory: false)
    }

    // The tile path for a specific pack, source, and Z, X, Y coordinates:
    // `Documents/MTOffline/<packID>/tiles/<sourceId>/<z>/<x>/<y>.pbf`
    internal static func tileURL(for packID: String, sourceId: String, z: Int, x: Int, y: Int) -> URL {
        return packDirectory(for: packID)
            .appendingPathComponent("tiles", isDirectory: true)
            .appendingPathComponent(sourceId, isDirectory: true)
            .appendingPathComponent("\(z)", isDirectory: true)
            .appendingPathComponent("\(x)", isDirectory: true)
            .appendingPathComponent("\(y).pbf", isDirectory: false)
    }
}
