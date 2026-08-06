//
//  Notch+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-01-08.
//

import SwiftUI

extension Notch: AnimatableByProperty {
    public static var animatableProperties: some AnimatableProperty<Self> {
        \.style
        \.position
        \.length
        \.depth
    }
}
