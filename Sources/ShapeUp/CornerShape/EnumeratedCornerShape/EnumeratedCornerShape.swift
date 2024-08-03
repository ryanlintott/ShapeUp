//
//  EnumeratedCornerShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-09.
//

import SwiftUI

/// A protocol used inside `EnumeratedCornerShape` to ensure `ShapeCorner` is `CaseIterable`, `Hashable`, and `Sendable`
public protocol EnumeratedCorner: CaseIterable, Hashable, Sendable { }

/// A corner shape defined by a named set of shape corners.
///
/// For example a triangle would include the corners top, bottom left, and bottom right.
public protocol EnumeratedCornerShape: CornerShape {
    /// An enumeration containing each named corner in the order they will be drawn.
    associatedtype ShapeCorner: EnumeratedCorner
    
    /// A dictionary storing the style of each corner by it's shape corner label.
    var styles: [ShapeCorner: CornerStyle?] { get set }
    
    /// Returns a dictionary with each point used to draw the shape stored with it's shape corner label.
    /// - Returns: A dictionary with each point used to draw the shape stored with it's shape corner label.
    nonisolated func points(in rect: CGRect) -> [ShapeCorner: CGPoint]
}

public extension EnumeratedCornerShape {
    func corners(in rect: CGRect) -> [Corner] {
        let points = points(in: rect)
        return ShapeCorner.allCases.compactMap {
            points[$0]?.corner(styles[$0] as? CornerStyle)
        }
    }
    
    /// Creates a copy of this shape changing the style of specified corners to the provided style.
    /// - Parameters:
    ///   - style: Style to apply to specified shape corners.
    ///   - shapeCorners: Shape corners on which to apply the specified style. Missing values will keep current style.
    /// - Returns: A copy of this shape changing the style of specified corners to the provided style.
    func applyingStyle(_ style: CornerStyle, shapeCorners: Set<ShapeCorner> = Set(ShapeCorner.allCases)) -> Self {
        var shape = self
        shapeCorners.forEach { shape.styles[$0] = style }
        return shape
    }
    
    /// Creates a copy of this shape changing the styles of specified corners.
    /// - Parameters:
    ///   - styles: Styles to apply to each specified shape corner. Nil or missing values will keep current style.
    /// - Returns: A copy of this shape changing the styles of specified corners.
    func applyingStyles(_ styles: [ShapeCorner: CornerStyle?]) -> Self {
        var shape = self
        styles.forEach { (shapeCorner, style) in
            if let style = style {
                shape.styles[shapeCorner] = style
            }
        }
        return shape
    }
}
