//
//  Corner+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-05-19.
//

import SwiftUI

extension Corner: Animatable {
    public typealias AnimatableData =
    AnimatablePair<
        Vector2,
        CornerStyle.AnimatableData
    >
    
    public var animatableData: AnimatableData {
        get {
            .init(
                Vector2(dx: x, dy: y),
                style.animatableData
            )
        }
        set {
            x = newValue.first.dx
            y = newValue.first.dy
            style.animatableData = newValue.second
        }
    }
}
