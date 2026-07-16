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
    /// Creates a copy updating each corner style to the new style.
    ///
    /// Nested styles inside a ``CornerStyle`` are not changed.
    /// - Parameter newStyle: Corner style to apply.
    /// - Returns: A copy with replaced corner styles.
    func cornerStyle(_ newStyle: CornerStyle) -> Self {
        transformCornerStyles { _ in newStyle }
    }

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

    /// Creates a copy updating the radius of each corner style.
    ///
    /// Nested styles inside a ``CornerStyle`` are not changed.
    /// - Parameter newRadius: Radius to apply.
    /// - Returns: A copy with changed corner radii.
    func changingRadius(to newRadius: RelatableValue) -> Self {
        transformCornerStyles {
            $0.changingRadius(to: newRadius)
        }
    }

    @available(*, deprecated, renamed: "cornerStyle(_:)")
    func applyingStyle(_ newStyle: CornerStyle) -> Self {
        cornerStyle(newStyle)
    }
}

extension Array: CornerStylable where Element: CornerStylable {
    public func transformCornerStyles(_ transform: @escaping @Sendable (CornerStyle) -> CornerStyle) -> [Element] {
        map { $0.transformCornerStyles(transform) }
    }
}

public extension Array where Element: CornerStylable {
    /// Creates an array of elements with a new corner style applied at specified indices.
    /// - Parameters:
    ///   - newStyle: A style that will be applied to specified corners.
    ///   - indices: Indices of the corners with which to apply the new style.
    /// - Returns: An array with the new corner style applied at the specified indices.
    func cornerStyle(_ newStyle: CornerStyle, corners indices: [Int]) -> [Element] {
        enumerated()
            .map { index, corner in
                indices.contains(index) ? corner.cornerStyle(newStyle) : corner
            }
    }
    
    @available(*, deprecated, renamed: "cornerStyle(_:corners:)")
    func applyingStyle(_ newStyle: CornerStyle, corners indices: [Int]) -> [Element] {
        cornerStyle(newStyle, corners: indices)
    }
    
    /// Creates an array of elements with a new corner style applied at a specified index.
    /// - Parameters:
    ///   - newStyle: A style that will be applied to a specified corner.
    ///   - index: Index of the corner with which to apply the new style.
    /// - Returns: An array with the new corner style applied at the specified index.
    func cornerStyle(_ newStyle: CornerStyle, corner index: Int) -> [Element] {
        cornerStyle(newStyle, corners: [index])
    }
    
    @available(*, deprecated, renamed: "cornerStyle(_:corner:)")
    func applyingStyle(_ newStyle: CornerStyle, corner index: Int) -> [Element] {
        cornerStyle(newStyle, corner: index)
    }
    
    /// Applies a new corner style to all elements in the array.
    /// - Parameter newStyle: A corner style that will be applied to every element.
    mutating func cornerStyle(_ newStyle: CornerStyle) {
        self = self.cornerStyle(newStyle)
    }

    /// Applies a default corner style to all automatic elements in the array.
    /// - Parameter defaultStyle: Style used to replace automatic corner styles.
    mutating func defaultCornerStyle(_ defaultStyle: CornerStyle) {
        self = self.defaultCornerStyle(defaultStyle)
    }
}
