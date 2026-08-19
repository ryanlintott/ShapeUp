//
//  RectAnchor+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-06-12.
//

import SwiftUI

extension RectAnchor: VectorArithmetic {
    /// The zero value.
    public static let zero: Self = .relative(x: 0, y: 0)
    
    /// Adds two values and produces their sum.
    public static func + (lhs: Self, rhs: Self) -> Self {
        (lhs.relativePoint.vector + rhs.relativePoint.vector).point.relative(to: CGRect.one)
    }
    
    /// Subtracts one value from another and produces their difference.
    public static func - (lhs: Self, rhs: Self) -> Self {
        (lhs.relativePoint.vector - rhs.relativePoint.vector).point.relative(to: CGRect.one)
    }
    
    /// Multiplies each component of this value by the given value.
    public mutating func scale(by rhs: Double) {
        self = relativePoint.vector.scaled(by: rhs).point.relative(to: CGRect.one)
    }
    
    /// The dot-product of the tuple of animatable values with itself.
    public var magnitudeSquared: Double {
        relativePoint.vector.magnitudeSquared
    }
}
