//
//  Vector2.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

/// A vector type used as an alternative to CGPoint
///
/// This type is mainly used internally so that CGPoint isn't publically extended with too many functions that may conflict with other user functions.
public struct Vector2: Equatable, Hashable, Codable, Sendable {
    /// Delta x
    public var dx: CGFloat
    /// Delta y
    public var dy: CGFloat
    
    /// Creates a vector
    /// - Parameters:
    ///   - dx: The x component
    ///   - dy: The y component
    public init(dx: CGFloat, dy: CGFloat) {
        self.dx = dx
        self.dy = dy
    }
}

public extension Vector2 {
    /// The zero vector
    static let zero = Self.init(dx: 0, dy: 0)
    
    /// A CGSize representation
    var size: CGSize { CGSize(width: dx, height: dy) }
    
    /// A CGRect representation with the origin at zero.
    var rect: CGRect { CGRect(x: 0, y: 0, width: dx, height: dy) }
}

extension Vector2: Vector2Representable {
    public var vector: Vector2 {
        self
    }
}

extension Vector2: Vector2Algebraic {
    public init(vector: Vector2) {
        self = vector
    }
}

extension Vector2: Vector2Transformable {
    public func repositioned(to point: some Vector2Representable) -> Vector2 {
        point.vector
    }
}
    
extension Vector2: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        dx *= rhs
        dy *= rhs
    }
}
