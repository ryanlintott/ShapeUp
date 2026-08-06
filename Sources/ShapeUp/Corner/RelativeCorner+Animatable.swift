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
        \.style.radius
        \.style.concaveInset
        \.style.relativeCorners.anchors
        \.style.relativeCorners.offsets
        \.style.relativeCorners.cornerStyles.radii
        \.style.relativeCorners.cornerStyles.concaveInsets
    }
}

extension Array where Element == RelativeCorner {
    var anchors: [RectAnchor] {
        get {
            map(\.anchor)
        }
        set {
            update(with: newValue) { corner, anchor in
                corner.anchor = anchor
            }
        }
    }

    var offsets: [Vector2] {
        get {
            map(\.offset)
        }
        set {
            update(with: newValue) { corner, offset in
                corner.offset = offset
            }
        }
    }
}
