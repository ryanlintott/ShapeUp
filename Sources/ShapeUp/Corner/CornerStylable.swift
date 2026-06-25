//
//  CornerStylable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-06-25.
//

import Foundation

/// A type that can have a ``CornerStyle`` or radius applied to it.
public protocol CornerStylable {
    /// Creates a copy with a new corner style applied to any ``CornerStyle`` parameters.
    /// - Parameter newStyle: Corner style to apply.
    /// - Returns: The same object with a changed corner style.
    func cornerStyle(_ newStyle: CornerStyle) -> Self
    
    /// Creates a copy with a new radius applied to any ``CornerStyle`` parameters.
    /// - Parameter newRadius: Radius to apply.
    /// - Returns: The same object with a changed radius.
    func changingRadius(to newRadius: RelatableValue) -> Self
}

public extension CornerStylable {
    @available(*, deprecated, renamed: "cornerStyle(_:)")
    func applyingStyle(_ newStyle: CornerStyle) -> Self {
        cornerStyle(newStyle)
    }
}

extension Array: CornerStylable where Element: CornerStylable {
    /// Creates an array of elements with a new specified corner style.
    /// - Parameter newStyle: A style that will be applied to every corner.
    /// - Returns: An array of elements with the new corner style.
    public func cornerStyle(_ newStyle: CornerStyle) -> [Element] {
        map { $0.cornerStyle(newStyle) }
    }
    
    public func changingRadius(to newRadius: RelatableValue) -> [Element] {
        map { $0.changingRadius(to: newRadius) }
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
}
