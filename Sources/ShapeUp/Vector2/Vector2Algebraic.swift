//
//  Vector2Algebraic.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

/// A protocol that adds basic vector2 algebraic functions.
///
/// Used on ``Vector2`` and can be applied to CGPoint.
///
/// Functionality includes: magnitude, normalizing, vector addition, vector subtraction, vector-scalar multiplication and division.
public protocol Vector2Algebraic: Vector2Representable, AdditiveArithmetic {
    /// Creates an object from a Vector2 representation.
    ///
    /// Object must not have any other properties.
    /// - Parameter vector: A Vector2 used to initialize x and y parameters.
    init(vector: Vector2)
}

public extension Vector2Algebraic {
    /// Creates a unit vector (magnitude of 1) pointing in a specified direction
    /// - Parameters:
    ///   - direction: The angle of the vector from the positive X axis.
    static func unitVector(direction: Angle) -> Self {
        let x = cos(direction.radians)
        let y = sin(direction.radians)
        let vector = Vector2(dx: x, dy: y)
        return .init(vector: vector)
    }
    
    /// Creates a vector with a specified length pointing in a specified direction.
    ///
    /// - Parameters:
    ///   - magnitude: Length of the vector.
    ///   - direction: The angle of the vector from the positive X axis.
    init(magnitude: CGFloat, direction: Angle) {
        self.init(vector: .unitVector(direction: direction) * magnitude)
    }
    
    /// Vector magnitude squared.
    var magnitudeSquared: Double {
        vector.dx * vector.dx + vector.dy * vector.dy
    }
    
    /// Vector magnitude. Length of the vector.
    var magnitude: CGFloat {
        sqrt(vector.magnitudeSquared)
    }
    
    /// The positive angle between the X axis and the vector.
    var direction: Angle? {
        // An vector without length has no direction
        guard vector != .zero else { return nil }
        
        return .radians(atan2(vector.dy, vector.dx)).minPositiveCoterminal
    }
    
    /// Normalized vector. A vector of length 1 pointing in the same direction.
    ///
    /// Zero vectors will be zero when normalized.
    var normalized: Self {
        if vector == .zero { return self }
        let magnitude = magnitude
        let vector = Vector2(dx: vector.dx / magnitude, dy: vector.dy / magnitude)
        return .init(vector: vector)
    }
    
    /// Vector negation.
    /// - Parameter vector: Vector to be negated.
    /// - Returns: A vector with the same magnitude pointing in the opposite direction.
    static prefix func - (vector: Self) -> Self {
        let vector = Vector2(dx: -vector.vector.dx, dy: -vector.vector.dy)
        return .init(vector: vector)
    }
    
    /// Vector addition.
    ///
    /// X and Y components of both vectors are added.
    ///
    /// Both vectors are placed head-to-tail. The result is a vector form the free tail to the free head.
    /// - Parameters:
    ///   - lhs: First vector.
    ///   - rhs: Second vector.
    /// - Returns: The sum of both vectors.
    static func + (lhs: Self, rhs: some Vector2Algebraic) -> Self {
        let vector = Vector2(dx: lhs.vector.dx + rhs.vector.dx, dy: lhs.vector.dy + rhs.vector.dy)
        return .init(vector: vector)
    }
    
    /// Vector subtraction
    ///
    /// After the second vector is negated, the X and Y components are added.
    ///
    /// Both vectors are placed head-to-head. The result is a vector from the first tail to the second.
    /// - Parameters:
    ///   - lhs: First vector
    ///   - rhs: Second vector
    /// - Returns: First vector plus the negated second vector.
    static func - (lhs: Self, rhs: some Vector2Algebraic) -> Self {
        lhs + -rhs
    }
    
    /// Vector addition assignment
    static func += (lhs: inout Self, rhs: some Vector2Algebraic) {
        lhs = lhs + rhs
    }
    
    /// Vector subtraction assignment
    static func -= (lhs: inout Self, rhs: some Vector2Algebraic) {
        lhs = lhs - rhs
    }
    
    /// Scalar-vector multiplication
    /// - Parameters:
    ///   - lhs: Scalar
    ///   - rhs: Vector
    /// - Returns: The vector after both components are multiplied by the scalar.
    static func * (lhs: CGFloat, rhs: Self) -> Self {
        let vector = Vector2(dx: lhs * rhs.vector.dx, dy: lhs * rhs.vector.dy)
        return .init(vector: vector)
    }
    
    /// Vector-Scalar multiplication
    /// - Parameters:
    ///   - lhs: Vector
    ///   - rhs: Scalar
    /// - Returns: The vector after both components are multiplied by the scalar.
    static func * (lhs: Self, rhs: CGFloat) -> Self {
        rhs * lhs
    }
    
    /// Size-vector multiplication
    /// - Parameters:
    ///   - lhs: Size
    ///   - rhs: Vector
    /// - Returns: The resulting vector from multiplying the x component by the width of the size and the y component by the height of the size.
    static func * (lhs: CGSize, rhs: Self) -> Self {
        let vector = Vector2(dx: lhs.width * rhs.vector.dx, dy: lhs.height * rhs.vector.dy)
        return .init(vector: vector)
    }
    
    /// Vector-size multiplication
    /// - Parameters:
    ///   - lhs: Vector
    ///   - rhs: Size
    /// - Returns: The resulting vector from multiplying the x component by the width of the size and the y component by the height of the size.
    static func * (lhs: Self, rhs: CGSize) -> Self {
        rhs * lhs
    }
    
    /// Vector-scalar division
    /// - Parameters:
    ///   - lhs: Vector
    ///   - rhs: Scalar
    /// - Returns: The vector after both components are divided by the scalar.
    static func / (lhs: Self, rhs: CGFloat) -> Self {
        guard rhs != 0 else { return .init(vector: .zero) }
        let vector = Vector2(dx: lhs.vector.dx / rhs, dy: lhs.vector.dy / rhs)
        return .init(vector: vector)
    }
    
    /// Vector-scalar division assignment
    static func /= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs / rhs
    }
    
    /// Scalar-vector multiplication assignment
    static func *= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs * rhs
    }
}
