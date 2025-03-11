//
//  StyleSetterOptions.swift
//  MapTilerSDK
//

/// Supporting type to add validation to another style related type.
public struct MTStyleSetterOptions: @unchecked Sendable, Codable {
    /// Boolean indicating whether filter conforms to the MapLibre Style Specification.
    ///
    /// Disabling validation is a performance optimization that should only be used
    /// if you have previously validated the values you will be passing to this function.
    public var shouldValidate: Bool = true

    public init(shouldValidate: Bool) {
        self.shouldValidate = shouldValidate
    }
}
