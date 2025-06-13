//
//  RectAnchor+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-06-12.
//

import SwiftUI

extension RectAnchor: VectorArithmetic {    
    /// The zero value.
    public static let zero: Self = .relative(0, 0)
    
    /// Adds two values and produces their sum.
    public static func + (lhs: Self, rhs: Self) -> Self {
        (lhs.relativePoint.vector + rhs.relativePoint.vector).point.relative(to: .one)
    }
    
    /// Subtracts one value from another and produces their difference.
    public static func - (lhs: Self, rhs: Self) -> Self {
        (lhs.relativePoint.vector - rhs.relativePoint.vector).point.relative(to: .one)
    }
    
    /// Multiplies each component of this value by the given value.
    public mutating func scale(by rhs: Double) {
        self = relativePoint.vector.scaled(by: rhs).point.relative(to: .one)
    }
    
    /// The dot-product of the tuple of animatable values with itself.
    public var magnitudeSquared: Double {
        relativePoint.vector.magnitudeSquared
    }
}
