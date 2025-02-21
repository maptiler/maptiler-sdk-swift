//
//  MTMapStyleVariant.swift
//  MapTilerSDK
//

/// Variants of the reference styles.
public enum MTMapStyleVariant: String, @unchecked Sendable, CaseIterable, Identifiable {
    public var id: String { rawValue }

    case reference
    case dark
    case light
    case pastel
    case night
    case shiny
    case topographique
    case vintage
    case lite
    case lines
    case background
}
