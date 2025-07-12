//
//  CornerStyle+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-05-20.
//

import SwiftUI

extension Optional<CornerStyle>: @retroactive Animatable {
    public var animatableData: CornerStyle.AnimatableData {
        get {
            switch self {
            case .none: CornerStyle.point.animatableData
            case let .some(value): value.animatableData
            }
        }
        set {
            self?.animatableData = newValue
        }
    }
}

extension CornerStyle: NestedAnimatable {
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
                self = .concave(radius: newValue.first, radiusOffset: newValue.second)
            }
        }
    }
    
    public typealias AnimatableData =
    AnimatablePair<
        RelatableValue,
        AnimatablePair<
            CGFloat,
            AnimatablePair<
                AnimatableArray<
                    CornerStyle.NestedAnimatableData
                >,
                AnimatableArray<
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
}
