//
//  CornerStyle+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-05-20.
//

import SwiftUI

extension CornerStyle: AnimatableByProperty {
    public static var animatableProperties: some AnimatableProperty<Self> {
        \.radius
        \.concaveInset
    }

    public static var recursiveAnimatableProperties: some AnimatableProperty<Self> {
        \.relativeCorners
        \.relativeCorners.cornerStyles
    }
}
