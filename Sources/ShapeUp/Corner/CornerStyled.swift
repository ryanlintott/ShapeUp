//
//  CornerStyled.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-23.
//

import Foundation

/// An object that has a single corner style that can be changed
public protocol CornerStyled: CornerStylable {
    /// The corner style applied to this object.
    var style: CornerStyle { get set }
}

public extension CornerStyled {
    func transformCornerStyles(_ transform: @escaping @Sendable (CornerStyle) -> CornerStyle) -> Self {
        var copy = self
        copy.style = transform(style)
        return copy
    }

    /// Creates a copy updating each corner style to the new style.
    ///
    /// Nested styles inside a ``CornerStyle`` are not changed.
    /// - Parameter newStyle: Corner style to apply.
    /// - Returns: A copy with replaced corner styles.
    func cornerStyle(_ newStyle: CornerStyle) -> Self {
        transformCornerStyles { _ in newStyle }
    }

    /// Radius of corner based on the style.
    var radius: RelatableValue {
        get {
            style.radius
        }
        set {
            style.radius = newValue
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
}

public extension Array where Element: CornerStyled {
    /// Array of corner styles used on each corner respectively.
    internal(set) var cornerStyles: [CornerStyle] {
        get {
            map(\.style)
        }
        set {
            self = self
                .cornerStyles(newValue)
        }
    }

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

    /// Creates an array of elements with a new corner style applied at a specified index.
    /// - Parameters:
    ///   - newStyle: A style that will be applied to a specified corner.
    ///   - index: Index of the corner with which to apply the new style.
    /// - Returns: An array with the new corner style applied at the specified index.
    func cornerStyle(_ newStyle: CornerStyle, corner index: Int) -> [Element] {
        cornerStyle(newStyle, corners: [index])
    }
    
    /// Creates an array of corners with the same positions and specified styles.
    /// - Parameter newStyles: An array of styles that will be applied to each corner respectively. Nil values will keep current style.
    /// - Returns: An array of corners with the same positions and specified styles.
    func cornerStyles(_ newStyles: [CornerStyle?]) -> [Element] {
        /// If newStyles only contains nil values return self
        if newStyles.compactMap(\.self).isEmpty { return Array(self) }
        
        /// Create an array of styles equal in length to the array of corners.
        let newStylesMatchingCount = newStyles + Array<CornerStyle?>(repeating: nil, count: Swift.max(count - newStyles.count, 0))
        
        return zip(self, newStylesMatchingCount)
            .map { corner, newStyle in
                // Apply a style if one is provided, otherwise use the current style.
                corner.cornerStyle(newStyle ?? corner.style)
            }
    }
}
