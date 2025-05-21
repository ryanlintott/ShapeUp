//
//  Vector2Representable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import simd
import SwiftUI

/// A type that has x and y values and can therefore be represented by a Vector2.
///
/// Used for ``Vector2`` and CGPoint.
/// Required for ``Vector2Transformable`` and ``Vector2Algebraic``
public protocol Vector2Representable {
    /// A Vector2 representation.
    var vector: Vector2 { get }
}

public extension Vector2Representable {
    /// A CGPoint representation
    ///
    /// An easy way to access a CGPoint representation without needing to know the object type.
    var point: CGPoint {
        self as? CGPoint ?? CGPoint(x: vector.dx, y: vector.dy)
    }
    
    /// Returns a corner at the same position with the applied style if not nil.
    ///
    /// If nil style is provided and the type is already a corner, the existing style will remain.
    /// - Parameter style: Corner style to use. Default is nil which renders as ``CornerStyle.point``.
    /// - Returns: Corner with the provided style and the same position as the point.
    func corner(_ style: CornerStyle? = nil) -> Corner {
        if style == nil { return corner }
        return Corner(style, point: point)
    }
    
    /// Corner at the same position. If the object is already a corner it just returns self.
    var corner: Corner {
        self as? Corner ?? Corner(nil, point: point)
    }
    
    /// Returns an anchor point relative to the specified rectangle.
    /// - Parameter rect: Rectangle used for relative position.
    /// - Returns: An anchor point relative to the specified rectangle.
    func relative(to rect: CGRect) -> RectAnchor {
        let relativePosition = vector - rect.origin.vector
        let x = rect.width == 0 ? 0 : relativePosition.dx / rect.width
        let y = rect.height == 0 ? 0 : relativePosition.dy / rect.height
        return .relative(x, y)
    }
    
    /// Creates a rectangle using this point as an anchor.
    /// - Parameters:
    ///   - size: Size of the rectangle.
    ///   - anchor: Location of the anchor point in the rectangle. Relative sizes relate to the rectangle size.
    /// - Returns: A rectangle with the specified size and this point as the anchor.
    func rect(size: CGSize, anchor: RectAnchor = .topLeft) -> CGRect {
        let anchorVector = size.rect()[anchor].vector
        return CGRect(origin: point.moved(-anchorVector), size: size)
    }
    
    
    /// Creates a rectangle using this point as an anchor.
    /// - Parameters:
    ///   - width: Width of the rectangle.
    ///   - height: Height of the rectangle.
    ///   - anchor: Location of the anchor point in the rectangle. Relative sizes relate to the rectangle size.
    /// - Returns: A rectangle with the specified size and this point as the anchor.
    func rect(width: CGFloat, height: CGFloat, anchor: RectAnchor = .topLeft) -> CGRect {
        rect(size: .init(width: width, height: height), anchor: anchor)
    }
}
