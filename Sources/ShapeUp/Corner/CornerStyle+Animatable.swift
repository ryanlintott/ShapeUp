//
//  CornerStyle+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-05-20.
//

import SwiftUI

//extension Optional<CornerStyle> {
//    public var animatableData: AnimatablePair<RelatableValue, CGFloat> {
//        get {
//            switch self {
//            case .none: CornerStyle.point.animatableData
//            case let .some(value): value.animatableData
//            }
//        }
//        set {
//            self?.animatableData = newValue
//        }
//    }
//}

//extension [CornerStyle] {
//    public typealias NestedAnimatableData =
//    VectorArray<
//        AnimatablePair<
//            RelatableValue,
//            CGFloat
//        >
//    >
//    
//    public var nestedAnimatableData: NestedAnimatableData {
//        get {
//            VectorArray(map(\.nestedAnimatableData))
//        }
//        set {
//            for i in indices {
//                if i < newValue.wrappedValue.count {
//                    self[i].nestedAnimatableData = newValue[i]
//                }
//            }
//        }
//    }
//}

extension CornerStyle: Animatable, NestedAnimatable {
    public typealias NestedAnimatableData =
    AnimatablePair<
        RelatableValue,
        CGFloat
    >

    public var nestedAnimatableData: NestedAnimatableData {
        get {
            switch self {
            case .point, .rounded, .straight, .cutout, .custom:
                .init(radius, .zero)
            case let .concave(radius, radiusOffset):
                .init(radius, radiusOffset)
            }
        }
        set {
            switch self {
            case .point, .rounded, .straight, .cutout, .custom:
                radius = newValue.first
            case .concave:
                self = .concave(newValue.first, radiusOffset: newValue.second)
            }
        }
    }
    
    public typealias AnimatableData =
    AnimatablePair<
        RelatableValue,
        AnimatablePair<
            CGFloat,
            AnimatablePair<
                VectorArray<
                    CornerStyle.NestedAnimatableData
                >,
                VectorArray<
                    RelativeCorner.NestedAnimatableData
                >
            >
        >
    >
    
    public var animatableData: AnimatableData {
        get {
            .init(
                radius,
                .init(
                    radiusOffset,
                    .init(
                        cornerStyles.nestedAnimatableData,
                        relativeCorners.nestedAnimatableData
                    )
                )
            )
        }
        set {
            radius = newValue.first
            radiusOffset = newValue.second.first
            cornerStyles.nestedAnimatableData = newValue.second.second.first
            relativeCorners.nestedAnimatableData = newValue.second.second.second
        }
    }
    
//    public var animatableData: AnimatablePair<RelatableValue, CGFloat> {
//        get {
//            switch self {
//            case .point, .rounded, .straight, .cutout, .custom:
//                .init(radius, .zero)
//            case let .concave(radius, radiusOffset):
//                .init(radius, radiusOffset)
//            }
//        }
//        set {
//            switch self {
//            case .point, .rounded, .straight, .cutout, .custom:
//                radius = newValue.first
//            case .concave:
//                self = .concave(newValue.first, radiusOffset: newValue.second)
//            }
//        }
//    }
}

//extension CornerStyle: VectorArithmetic {
//    /// The zero value.
//    ///
//    /// Zero is the identity element for addition. For any value,
//    /// `x + .zero == x` and `.zero + x == x`.
//    public static let zero: Self = .point
//    
//    /// Adds two values and produces their sum.
//    public static func + (lhs: Self, rhs: Self) -> Self {
//        switch lhs {
//        case .point:
//                .point
//        case .rounded:
//                .rounded(lhs.radius + rhs.radius)
//        case .straight:
//                .straight(lhs.radius + rhs.radius)
//        case .concave:
//                .concave(
//                    lhs.radius + rhs.radius,
//                    radiusOffset: lhs.radiusOffset + rhs.radiusOffset
//                )
//        case .cutout:
//                .cutout(
//                    lhs.radius + rhs.radius,
//                    cornerStyles: (VectorArray(lhs.cornerStyles) + VectorArray(rhs.cornerStyles)).wrappedValue
//                )
//        case .custom:
//                .custom(
//                    lhs.radius + rhs.radius,
//                    relativeCorners: (VectorArray(lhs.relativeCorners) + VectorArray(rhs.relativeCorners)).wrappedValue
//                )
//        }
//    }
//    
//    /// Subtracts one value from another and produces their difference.
//    public static func - (lhs: Self, rhs: Self) -> Self {
//        switch lhs {
//        case .point:
//                .point
//        case .rounded:
//                .rounded(lhs.radius - rhs.radius)
//        case .straight:
//                .straight(lhs.radius - rhs.radius)
//        case .concave:
//                .concave(lhs.radius - rhs.radius, radiusOffset: lhs.radiusOffset - rhs.radiusOffset)
//        case .cutout:
//                .cutout(lhs.radius - rhs.radius, cornerStyles: (VectorArray(rhs.cornerStyles) - VectorArray(lhs.cornerStyles)).wrappedValue)
//        case .custom:
//                .custom(lhs.radius - rhs.radius, relativeCorners: (VectorArray(rhs.relativeCorners) - VectorArray(lhs.relativeCorners)).wrappedValue)
//        }
//    }
//    
//    /// Multiplies each component of this value by the given value.
//    public mutating func scale(by rhs: Double) {
//        radius.scaled(by: rhs)
//        radiusOffset.scaled(by: rhs)
//        cornerStyles = VectorArray(cornerStyles).scaled(by: rhs).wrappedValue
//        relativeCorners = VectorArray(relativeCorners).scaled(by: rhs).wrappedValue
//    }
//    
//    /// The dot-product of the tuple of animatable values with itself.
//    public var magnitudeSquared: Double {
//        radius.magnitudeSquared
//        + radiusOffset.magnitudeSquared
//        + VectorArray(cornerStyles).magnitudeSquared
//        + VectorArray(relativeCorners).magnitudeSquared
//    }
//    
//    /// Returns a Boolean value indicating whether two values are equal.
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        switch (lhs, rhs) {
//        case (.point, .point),
//            (.rounded, .rounded),
//            (.concave, .concave),
//            (.straight, .straight),
//            (.cutout, .cutout),
//            (.custom, .custom):
//            lhs.radius == rhs.radius
//            && lhs.radiusOffset == rhs.radiusOffset
//            && lhs.cornerStyles == rhs.cornerStyles
//            && lhs.relativeCorners == rhs.relativeCorners
//        case (.point, _),
//            (.rounded, _),
//            (.concave, _),
//            (.straight, _),
//            (.cutout, _),
//            (.custom, _):
//            false
//        }
//    }
//}
