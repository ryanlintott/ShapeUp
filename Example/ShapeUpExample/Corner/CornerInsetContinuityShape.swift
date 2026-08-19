//
//  CornerInsetContinuityShape.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2026-07-14.
//

import ShapeUp
import SwiftUI

struct CornerInsetContinuityShape: CornerShape, AnimatableProperties {
    var insetAmount: CGFloat = 0
    let closed = true
    
    var angleDegrees: CGFloat
    var style: CornerStyle
    
    static var animatableProperties: some AnimatableProperty<Self> {
        \.angleDegrees
        \.style
    }

    func corners(in rect: CGRect) -> [Corner] {
        rect[.topRight]
        rect[.bottomRight]
        
        Self.controlPoints(in: rect, angleDegrees: angleDegrees)
            .corners
            .cornerStyle(style, corner: 1)
    }
    
    static func controlPoints(in rect: CGRect, angleDegrees: CGFloat) -> [CGPoint] {
        [
            rect[0.66, 0.5].rotated(.degrees(angleDegrees / 2), anchor: rect[0.32, 0.5]),
            rect[0.32, 0.5],
            rect[0.66, 0.5].rotated(.degrees(-angleDegrees / 2), anchor: rect[0.32, 0.5])
        ]
    }
}
