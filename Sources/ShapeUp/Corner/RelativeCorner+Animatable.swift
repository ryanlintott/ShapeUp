//
//  RelativeCorner+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-06-12.
//

import SwiftUI

extension RelativeCorner: NestedAnimatable {
    public typealias NestedAnimatableData =
    AnimatablePair<
        RectAnchor,
        AnimatablePair<
            Vector2,
            CornerStyle.NestedAnimatableData
        >
    >

    public var nestedAnimatableData: NestedAnimatableData {
        get {
            .init(
                anchor,
                .init(
                    offset,
                    style.nestedAnimatableData
                )
            )
        }
        set {
            anchor = newValue.first
            offset = newValue.second.first
            style.nestedAnimatableData = newValue.second.second
        }
    }
    
    public typealias AnimatableData =
    AnimatablePair<
        RectAnchor,
        AnimatablePair<
            Vector2,
            CornerStyle.AnimatableData
        >
    >
    
    public var animatableData: AnimatableData {
        get {
            .init(
                anchor,
                .init(
                    offset,
                    style.animatableData
                )
            )
        }
        set {
            anchor = newValue.first
            offset = newValue.second.first
            style.animatableData = newValue.second.second
        }
    }
}
