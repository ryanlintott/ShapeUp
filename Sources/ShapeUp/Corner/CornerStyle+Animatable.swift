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
            .init(
                radius,
                concaveInset
            )
        }
        set {
            radius = newValue.first
            concaveInset = newValue.second
        }
    }
    
    public typealias AnimatableData =
    
    AnimatablePair<
        RelatableValue,
        AnimatablePair<
            CGFloat,
            AnimatableArray<
                RelativeCorner.NestedAnimatableData
            >
        >
    >
    public var animatableData: AnimatableData {
        get {
            .init(
                radius,
                .init(
                    concaveInset,
                    relativeCorners.nestedAnimatableData
                )
            )
        }
        set {
            radius = newValue.first
            concaveInset = newValue.second.first
            relativeCorners.nestedAnimatableData = newValue.second.second
        }
    }
}
