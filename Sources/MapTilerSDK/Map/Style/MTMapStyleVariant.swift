//
//  MTMapStyleVariant.swift
//  MapTilerSDK
//

/// Variants of the reference styles.
public enum MTMapStyleVariant: String, Sendable, CaseIterable, Identifiable {
    /// Unique id of the style variant.
    public var id: String { rawValue }

    /// Default variant.
    case defaultVariant = "default"

    /// Dark variant.
    case dark

    /// Light variant.
    case light

    /// Pastel variant.
    case pastel

    /// Night variant.
    case night

    /// Shiny variant.
    case shiny

    /// Topographique variant.
    case topographique

    /// Lite variant.
    case lite

    /// Lines variant.
    case lines

    /// Background variant
    case background

    /// Vivid variant
    case vivid
}
