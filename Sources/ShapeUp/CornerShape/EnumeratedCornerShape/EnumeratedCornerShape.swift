//
//  EnumeratedCornerShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-09.
//

import SwiftUI

/// A protocol used inside ``EnumeratedCornerShape`` to ensure `ShapeCorner` is `CaseIterable`, `Hashable`, and `Sendable`
public protocol EnumeratedCorner: CaseIterable, Hashable, Sendable { }

/// A corner shape defined by a named set of shape corners.
///
/// For example a triangle would include the corners top, bottom left, and bottom right.
public protocol EnumeratedCornerShape: CornerShape, CornerStylable {
    /// An enumeration containing each named corner in the order they will be drawn.
    associatedtype ShapeCorner: EnumeratedCorner
    
    /// A dictionary storing the style of each corner by its shape corner label.
    ///
    /// A corner with no matching entry uses ``CornerStyle/automatic``.
    var styles: [ShapeCorner: CornerStyle] { get set }
    
    /// Returns a dictionary with each point used to draw the shape stored with its shape corner label.
    ///
    /// ``corners(in:)`` emits points in `ShapeCorner.allCases` order. A case with no matching
    /// point in the returned dictionary is omitted.
    /// - Parameter rect: The rectangle in which to position the points.
    /// - Returns: A dictionary with each point used to draw the shape stored with its shape corner label.
    func points(in rect: CGRect) -> [ShapeCorner: CGPoint]
}

public extension EnumeratedCornerShape {
    func corners(in rect: CGRect) -> [Corner] {
        let points = points(in: rect)
        return ShapeCorner.allCases.compactMap {
            points[$0]?.corner(styles[$0] ?? nil)
        }
    }
    
    /// Creates a copy of this shape changing the style of specified corners to the provided style.
    /// - Parameters:
    ///   - newStyle: Style to apply to specified shape corners.
    ///   - shapeCorners: Shape corners on which to apply the specified style. Missing values will keep current style.
    /// - Returns: A copy of this shape changing the style of specified corners to the provided style.
    func cornerStyle(_ newStyle: CornerStyle, shapeCorners: Set<ShapeCorner>) -> Self {
        var shape = self
        shapeCorners.forEach { shape.styles[$0] = newStyle }
        return shape
    }
    
    func transformCornerStyles(_ transform: @escaping @Sendable (CornerStyle) -> CornerStyle) -> Self {
        var shape = self
        ShapeCorner.allCases.forEach { shapeCorner in
            shape.styles[shapeCorner] = transform(shape.styles[shapeCorner] ?? .automatic)
        }
        return shape
    }
    
    /// Creates a copy of this shape changing the style of specified corner to the provided style.
    /// - Parameters:
    ///   - style: Style to apply to specified shape corners.
    ///   - shapeCorner: Shape corner on which to apply the specified style.
    /// - Returns: A copy of this shape changing the style of specified corners to the provided style.
    func cornerStyle(_ style: CornerStyle, shapeCorner: ShapeCorner) -> Self {
        cornerStyle(style, shapeCorners: [shapeCorner])
    }
    
    /// Creates a copy of this shape changing the styles of specified corners.
    /// - Parameters:
    ///   - styles: Styles to apply to each specified shape corner. Nil or missing values will keep current style.
    /// - Returns: A copy of this shape changing the styles of specified corners.
    func cornerStyles(_ styles: [ShapeCorner: CornerStyle?]) -> Self {
        var shape = self
        styles.forEach { (shapeCorner, style) in
            if let style = style {
                shape.styles[shapeCorner] = style
            }
        }
        return shape
    }

    @available(*, deprecated, message: "Use `defaultCornerStyle(_:)` to replace only automatic styles, or `transformCornerStyles { _ in style }` to replace every style.")
    func applyingStyle(_ newStyle: CornerStyle) -> Self {
        transformCornerStyles { _ in newStyle }
    }

    @available(*, deprecated, renamed: "cornerStyle(_:shapeCorners:)")
    func applyingStyle(_ newStyle: CornerStyle, shapeCorners: Set<ShapeCorner>) -> Self {
        cornerStyle(newStyle, shapeCorners: shapeCorners)
    }
    
    @available(*, deprecated, renamed: "cornerStyles(_:)")
    func applyingStyles(_ styles: [ShapeCorner: CornerStyle?]) -> Self {
        cornerStyles(styles)
    }
}
