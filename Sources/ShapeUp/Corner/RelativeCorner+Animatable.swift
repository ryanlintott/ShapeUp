//
//  RelativeCorner+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-06-12.
//

import SwiftUI

extension RelativeCorner: AnimatableByProperty {
    public static var animatableProperties: some AnimatableProperty<Self> {
        \.anchor
        \.offset
    }
    
    public static var recursiveAnimatableProperties: some AnimatableProperty<Self> {
        \.style
        \.style.relativeCorners
        \.style.relativeCorners.cornerStyles
    }
}
