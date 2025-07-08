//
//  NotchStyle+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-01-08.
//

import SwiftUI

extension NotchStyle: Animatable {
    public typealias AnimatableData = AnimatableArray<RelativeCorner.AnimatableData>
    
    public var animatableData: AnimatableData {
        get {
            relativeCorners.animatableData
        }
        set {
            relativeCorners.animatableData = newValue
        }
    }
}
