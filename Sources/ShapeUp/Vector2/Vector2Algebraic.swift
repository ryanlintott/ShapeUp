//
//  Vector2Algebraic.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

public protocol Vector2Algebraic: Vector2Representable, Comparable { }

extension Vector2Algebraic {
    // Vector negation
    static prefix func - (vector: Self) -> Self {
        let vector = Vector2(dx: -vector.vector.dx, dy: -vector.vector.dy)
        return .init(vector: vector)
    }
    
    // Vector addition
    static func + <T: Vector2Algebraic>(lhs: Self, rhs: T) -> Self {
        let vector = Vector2(dx: lhs.vector.dx + rhs.vector.dx, dy: lhs.vector.dy + rhs.vector.dy)
        return .init(vector: vector)
    }
    
    // Vector subtraction
    static func - <T: Vector2Algebraic>(lhs: Self, rhs: T) -> Self {
        return lhs + -rhs
    }
    
    // Vector addition assignment
    static func += <T: Vector2Algebraic>(lhs: inout Self, rhs: T) {
        lhs = lhs + rhs
    }
    
    // Vector subtraction assignment
    static func -= <T: Vector2Algebraic>(lhs: inout Self, rhs: T) {
        lhs = lhs - rhs
    }
    
    // Scalar-vector multiplication
    static func * (lhs: CGFloat, rhs: Self) -> Self {
        let vector = Vector2(dx: lhs * rhs.vector.dx, dy: lhs * rhs.vector.dy)
        return .init(vector: vector)
    }
    
    static func * (lhs: Self, rhs: CGFloat) -> Self {
        return rhs * lhs
    }
    
    // Vector-scalar division
    static func / (lhs: Self, rhs: CGFloat) -> Self {
        guard rhs != 0 else { return .init(vector: .zero) }
        let vector = Vector2(dx: lhs.vector.dx / rhs, dy: lhs.vector.dy / rhs)
        return .init(vector: vector)
    }
    
    // Vector-scalar division assignment
    static func /= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs / rhs
    }
    
    // Scalar-vector multiplication assignment
    static func *= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs * rhs
    }
    
    // Vector magnitude (length)
    var magnitude: CGFloat {
        return sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
    }
    
    // Vector normalization
    var normalized: Self {
        let vector = Vector2(dx: vector.dx / magnitude, dy: vector.dy / magnitude)
        return .init(vector: vector)
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.magnitude < rhs.magnitude
    }
}
