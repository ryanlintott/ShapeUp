//
//  RelativeCorner.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-06-12.
//

import SwiftUI

extension RelativeCorner: NestedAnimatable {
    public typealias NestedAnimatableData =
    AnimatablePair<
        RectAnchor,
        CornerStyle.NestedAnimatableData
    >

    public var nestedAnimatableData: NestedAnimatableData {
        get {
            .init(anchorPoint, style.nestedAnimatableData)
        }
        set {
            anchorPoint = newValue.first
            style.nestedAnimatableData = newValue.second
        }
    }
    
    public typealias AnimatableData =
    AnimatablePair<
        RectAnchor,
        CornerStyle.AnimatableData
    >
    
    public var animatableData: AnimatableData {
        get {
            .init(anchorPoint, style.animatableData)
        }
        set {
            anchorPoint = newValue.first
            style.animatableData = newValue.second
        }
    }
}

//extension RelativeCorner: VectorArithmetic {
//    /// The zero value.
//    ///
//    /// Zero is the identity element for addition. For any value,
//    /// `x + .zero == x` and `.zero + x == x`.
//    public static let zero: Self = .init(anchorPoint: .relative(.zero))
//    
//    /// Adds two values and produces their sum.
//    public static func + (lhs: Self, rhs: Self) -> Self {
//        .init(
//            lhs.style + rhs.style,
//            anchorPoint: lhs.anchorPoint + rhs.anchorPoint
//        )
//    }
//    
//    /// Subtracts one value from another and produces their difference.
//    public static func - (lhs: Self, rhs: Self) -> Self {
//        .init(
//            lhs.style - rhs.style,
//            anchorPoint: lhs.anchorPoint - rhs.anchorPoint
//        )
//    }
//    
//    /// Multiplies each component of this value by the given value.
//    public mutating func scale(by rhs: Double) {
//        style.scale(by: rhs)
//        anchorPoint.scale(by: rhs)
//    }
//    
//    /// The dot-product of the tuple of animatable values with itself.
//    public var magnitudeSquared: Double {
//        style.magnitudeSquared
//        + anchorPoint.magnitudeSquared
//    }
//    
//    /// Returns a Boolean value indicating whether two values are equal.
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        lhs.style == rhs.style
//        && lhs.anchorPoint == rhs.anchorPoint
//    }
//}
