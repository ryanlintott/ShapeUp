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
            .init(anchor, style.nestedAnimatableData)
        }
        set {
            anchor = newValue.first
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
            .init(anchor, style.animatableData)
        }
        set {
            anchor = newValue.first
            style.animatableData = newValue.second
        }
    }
}
