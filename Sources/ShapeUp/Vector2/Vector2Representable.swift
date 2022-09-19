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
/// Used for Vector2 and CGPoint.
/// Required for Vector2Transformable and Vector2Algebraic
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
    
    /// Returns a corner at the same position with the applied style
    /// - Parameter style: Corner style to use. Default is .point.
    /// - Returns: Corner with the provided style and the same position as the point.
    func corner(_ style: CornerStyle? = nil) -> Corner {
        Corner(style ?? .point, point: point)
    }
}
