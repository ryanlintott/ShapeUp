//
//  Notch+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-01-08.
//

import SwiftUI

extension Notch: Animatable {
    public typealias AnimatableData = 
    AnimatablePair<
        NotchStyle.AnimatableData,
        AnimatablePair<
            RelatableValue,
            AnimatablePair<
                RelatableValue,
                RelatableValue
            >
        >
    >
    
    public var animatableData: AnimatableData {
        get {
            AnimatablePair(
                style.animatableData,
                AnimatablePair(
                    position,
                    AnimatablePair(
                        length,
                        depth
                    )
                )
            )
        }
        set {
            style.animatableData = newValue.first
            position = newValue.second.first
            length = newValue.second.second.first
            depth = newValue.second.second.second
        }
    }
}