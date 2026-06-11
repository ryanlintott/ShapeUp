//
//  CornerStyled.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-23.
//

import Foundation

/// A type can can have a ``CornerStyle`` or a radius applied to it.
public protocol CornerStylable {
    /// Creates a copy with a new corner style applied to any ``CornerStyle`` parameters.
    /// - Parameter newStyle: Corner style to apply.
    /// - Returns: The same object with a changed corner style.
    func applyingStyle(_ newStyle: CornerStyle) -> Self
    
    /// Creates a copy with a new radius applied to any ``CornerStyle`` parameters.
    /// - Parameter newRadius: Radius to apply.
    /// - Returns: The same object with a changed radius.
    func changingRadius(to newRadius: RelatableValue) -> Self
}

extension Array: CornerStylable where Element: CornerStylable {
    /// Creates an array of corners with the same positions and a new specified style.
    /// - Parameter newStyle: A style that will be applied to every corner.
    /// - Returns: An array of corners with the same positions and a new specified style.
    public func applyingStyle(_ newStyle: CornerStyle) -> [Element] {
        map { $0.applyingStyle(newStyle) }
    }
    
    public func changingRadius(to newRadius: RelatableValue) -> [Element] {
        map { $0.changingRadius(to: newRadius) }
    }
}

public extension Array where Element: CornerStylable {
    /// Creates an array of corners with the same positions and a new specified style applied to specified corners.
    /// - Parameters:
    ///   - newStyle: A style that will be applied to specified corners.
    ///   - indices: Indices of the corners with which to apply the new style.
    /// - Returns: An array of corners with the same positions and a new specified style applied to specified corners.
    func applyingStyle(_ newStyle: CornerStyle, corners indices: [Int]) -> [Element] {
        enumerated()
            .map { index, corner in
                indices.contains(index) ? corner.applyingStyle(newStyle) : corner
            }
    }
    
    /// Creates an array of corners with the same positions and a new specified style applied to a specified corner.
    /// - Parameters:
    ///   - newStyle: A style that will be applied to a specified corner.
    ///   - index: Index of the corner with which to apply the new style.
    /// - Returns: An array of corners with the same positions and a new specified style applied to a specified corner.
    func applyingStyle(_ newStyle: CornerStyle, corner index: Int) -> [Element] {
        applyingStyle(newStyle, corners: [index])
    }
    
    /// Applies a new style to all corners in the array.
    /// - Parameter newStyle: A style that will be applied to every corner.
    mutating func applyStyle(_ newStyle: CornerStyle) {
        self = self.applyingStyle(newStyle)
    }
}

/// An object that has a single corner style that can be changed
public protocol CornerStyled: CornerStylable {
    var style: CornerStyle { get set }
}

public extension CornerStyled {
    /// Radius of corner based on the style.
    var radius: RelatableValue {
        get {
            style.radius
        }
        set {
            style.radius = newValue
        }
    }
    
    func applyingStyle(_ newStyle: CornerStyle) -> Self {
        var copy = self
        copy.style = newStyle
        return copy
    }
    
    func changingRadius(to newRadius: RelatableValue) -> Self {
        var copy = self
        copy.radius = newRadius
        return copy
    }
}

public extension Array where Element: CornerStyled {
    /// Array of corner styles used on each corner respectively.
    var cornerStyles: [CornerStyle] {
        get {
            map(\.style)
        }
        set {
            self = self
                .applyingStyle(.point)
                .applyingStyles(newValue)
        }
    }
    
    /// Creates an array of corners with the same positions and specified styles.
    /// - Parameter newStyles: An array of styles that will be applied to each corner respecitvely. Nil values will keep current style.
    /// - Returns: An array of corners with the same positions and specified styles.
    func applyingStyles(_ newStyles: [CornerStyle?]) -> [Element] {
        /// If newStyles only contains nil values return self
        if newStyles.compactMap(\.self).isEmpty { return Array(self) }
        
        /// Create an array of styles equal in length to the array of corners.
        let newStylesMatchingCount = newStyles + Array<CornerStyle?>(repeating: nil, count: Swift.max(count - newStyles.count, 0))
        
        return zip(self, newStylesMatchingCount)
            .map { corner, newStyle in
                // Apply a style if one is provided, otherwise use the current style.
                corner.applyingStyle(newStyle ?? corner.style)
            }
    }
    
    /// Applies new styles to this array of corners.
    /// - Parameter newStyles: An array of styles that will be applied to each corner respecitvely. Nil values will keep current style.
    mutating func applyStyles(_ newStyles: [CornerStyle?]) {
        self = self.applyingStyles(newStyles)
    }
}
