//
//  Corner+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-05-19.
//

import SwiftUI

extension Corner: AnimatableByProperty {
    public static var animatableProperties: some AnimatableProperty<Self> {
        \.x
        \.y
        \.style
    }
}
