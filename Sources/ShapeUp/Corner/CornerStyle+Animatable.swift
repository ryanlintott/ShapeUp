//
//  CornerStyle+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-05-20.
//

import SwiftUI

extension CornerStyle: AnimatableProperties {
    public static var animatableProperties: some AnimatableProperty<Self> {
        \.radius
        \.concaveInset
        \.relativeCorners.anchors
        \.relativeCorners.offsets
        \.relativeCorners.cornerStyles.radii
        \.relativeCorners.cornerStyles.concaveInsets
    }
}

extension Array where Element == CornerStyle {
    var radii: [RelatableValue] {
        get {
            map(\.radius)
        }
        set {
            update(with: newValue) { style, radius in
                style.radius = radius
            }
        }
    }

    var concaveInsets: [CGFloat] {
        get {
            map(\.concaveInset)
        }
        set {
            update(with: newValue) { style, concaveInset in
                style.concaveInset = concaveInset
            }
        }
    }
}
