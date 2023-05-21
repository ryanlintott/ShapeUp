//
//  SwiftUIView.swift
//  
//
//  Created by Ryan Lintott on 2023-05-19.
//

import SwiftUI

extension Corner: Animatable {
    public var animatableData: AnimatablePair<Vector2, CornerStyle.AnimatableData> {
        get {
            .init(Vector2(dx: x, dy: y), style.animatableData)
        }
        set {
            self.update(with: newValue)
        }
    }
    
    mutating func update(with newValue: AnimatableData) {
        x = newValue.first.dx
        y = newValue.first.dy
        style.update(with: newValue.second)
    }
}
