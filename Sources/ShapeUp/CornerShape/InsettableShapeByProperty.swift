//
//  InsettableShapeByProperty.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-16.
//

import SwiftUI

/// An insettable shape that stores its inset amount in a property rather than using the function.
///
/// Inset versions of this type will always share the same type using the insetAmount property in the path function to draw the shape with the appropriate inset.
@MainActor
public protocol InsettableShapeByProperty: InsettableShape {
    /// Inset amount stored as a property.
    ///
    /// Initialize this value with zero and the inset function will adjust it whenever you inset the shape.
    ///
    ///     var insetAmount: CGFloat = 0
    ///
    /// Do not use this value in the corners function as that function needs to output corners with zero inset.
    var insetAmount: CGFloat { get set }
}

public extension InsettableShapeByProperty {
    /// Creates the same shape with an updated inset amount property.
    ///
    /// The shape must use this property in its path function to draw with the appropriate inset.
    /// - Parameter amount: Inset amount
    /// - Returns: The same shape type with the inset amount saved to
    nonisolated func inset(by amount: CGFloat) -> Self {
        MainActor.assumeIsolated {
            var shape = self
            shape.insetAmount += amount
            return shape
        }
    }
}
