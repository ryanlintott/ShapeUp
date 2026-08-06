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
            self = self.update(with: newValue) { element, newValue in
                var updatedElement = element
                updatedElement.radius = newValue
                return updatedElement
            }
        }
    }
    
    var concaveInsets: [CGFloat] {
        get {
            map(\.concaveInset)
        }
        set {
            self = self.update(with: newValue) { element, newValue in
                var updatedElement = element
                updatedElement.concaveInset = newValue
                return updatedElement
            }
        }
    }
}
