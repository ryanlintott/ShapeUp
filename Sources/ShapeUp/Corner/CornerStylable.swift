//
//  CornerStylable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-06-25.
//

import Foundation

/// A type containing one or more corner styles that can be transformed.
public protocol CornerStylable {
    /// Creates a copy transforming each corner style contained by this value.
    ///
    /// Nested styles inside a ``CornerStyle`` are not transformed.
    /// - Parameter transform: A transformation applied to each corner style.
    /// - Returns: A copy containing the transformed corner styles.
    func transformCornerStyles(_ transform: @escaping @Sendable (CornerStyle) -> CornerStyle) -> Self
}

public extension CornerStylable {
    /// Creates a copy updating any automatic corner styles to the supplied default style.
    ///
    /// Nested styles inside a ``CornerStyle`` are not changed.
    /// - Parameter defaultStyle: Corner style used to replace automatic corner styles.
    /// - Returns: A copy with automatic corner styles replaced with the supplied default style.
    func defaultCornerStyle(_ defaultStyle: CornerStyle) -> Self {
        transformCornerStyles { style in
            style == .automatic ? defaultStyle : style
        }
    }
}

extension Array: CornerStylable where Element: CornerStylable {
    public func transformCornerStyles(_ transform: @escaping @Sendable (CornerStyle) -> CornerStyle) -> [Element] {
        map { $0.transformCornerStyles(transform) }
    }
}
