//
//  NestedAnimatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-08.
//

import SwiftUI

/// A type that can animate ``SwiftUICore.Animatable`` properties to one level.
protocol NestedAnimatable: Animatable {
    /// The type defining the nested data to animate.
    ///
    /// This type is intended to be used inside ``SwiftUICore.AnimatableData``. It cannot reference itself or another type that references itself.
    associatedtype NestedAnimatableData: VectorArithmetic

    /// The nested data to animate.
    var nestedAnimatableData: Self.NestedAnimatableData { get set }
}

extension Array where Element: NestedAnimatable {
    var nestedAnimatableData: AnimatableArray<Element.NestedAnimatableData> {
        get {
            AnimatableArray(map(\.nestedAnimatableData))
        }
        set {
            let count = Swift.min(count, newValue.wrappedValue.count)
            for i in 0..<count {
                self[i].nestedAnimatableData = newValue.wrappedValue[i]
            }
        }
    }
}
