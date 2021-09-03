//
//  Vector2Transformable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public protocol Vector2Transformable: Vector2Representable, Comparable {
    var dx: CGFloat { get }
    var dy: CGFloat { get }
    init(dx: CGFloat, dy: CGFloat)
}

extension Vector2Transformable {
    public var vector: Vector2 { Vector2(dx: dx, dy: dy) }
}

extension Vector2Transformable {
    // Vector negation
    static prefix func - (vector: Self) -> Self {
        return Self(dx: -vector.dx, dy: -vector.dy)
    }
    
    // Vector addition
    static func + <T: Vector2Transformable>(lhs: Self, rhs: T) -> Self {
        return Self(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }
    
    // Vector subtraction
    static func - <T: Vector2Transformable>(lhs: Self, rhs: T) -> Self {
        return lhs + -rhs
    }
    
    // Vector addition assignment
    static func += <T: Vector2Transformable>(lhs: inout Self, rhs: T) {
        lhs = lhs + rhs
    }
    
    // Vector subtraction assignment
    static func -= <T: Vector2Transformable>(lhs: inout Self, rhs: T) {
        lhs = lhs - rhs
    }
    
    // Scalar-vector multiplication
    static func * (lhs: CGFloat, rhs: Self) -> Self {
        return Self(dx: lhs * rhs.dx, dy: lhs * rhs.dy)
    }
    
    static func * (lhs: Self, rhs: CGFloat) -> Self {
        return rhs * lhs
    }
    
    // Vector-scalar division
    static func / (lhs: Self, rhs: CGFloat) -> Self {
        guard rhs != 0 else { return Self(dx: 0, dy: 0) }
        return Self(dx: lhs.dx / rhs, dy: lhs.dy / rhs)
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
        return sqrt(dx * dx + dy * dy)
    }
    
    // Vector normalization
    var normalized: Self {
        return Self(dx: dx / magnitude, dy: dy / magnitude)
    }
    
    func moved<T: Vector2Representable>(_ distance: T) -> Self {
        self + distance.vector
    }
    
    func rotated<T: Vector2Representable>(_ angle: Angle, anchor: T) -> Self {
        let p = self - anchor.vector
        let s = CGFloat(sin(angle.radians))
        let c = CGFloat(cos(angle.radians))
        let pRotated = Self(dx: p.dx * c - p.dy * s, dy: p.dx * s + p.dy * c)
        return pRotated + anchor.vector
    }
    
    func rotated(_ angle: Angle) -> Self {
        rotated(angle, anchor: CGPoint.zero)
    }
    
    func mirrored<T: Vector2Representable, U: Vector2Representable>(mirrorLineStart: T, mirrorLineEnd: U) -> Self {
        let vectorToPoint = self - mirrorLineStart.vector
        let angle = Angle.radians(Angle(self, mirrorLineStart, mirrorLineEnd).radians * 2)
        return self - vectorToPoint + vectorToPoint.rotated(-angle)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.magnitude < rhs.magnitude
    }
}
