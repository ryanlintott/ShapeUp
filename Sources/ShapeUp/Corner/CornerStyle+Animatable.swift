//
//  CornerStyle+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-05-20.
//

import SwiftUI

extension CornerStyle: AnimatableProperties {
    public static var animatableProperties: some AnimatableProperty<Self> {
        AnimatablePropertyGroup(id: \.name) {
            \.radius
            \.concaveInset
            \.relativeCorners
        }
    }
}
