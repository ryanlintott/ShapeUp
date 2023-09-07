//
//  AnimatableArray+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-09-06.
//

import SwiftUI

public struct AnimatableArray<Element: VectorArithmetic>: ExpressibleByArrayLiteral {
    public var animatableData: [Element]
    
    public var count: Int { animatableData.count }

    public init<T: Animatable>(animatable: [T]) where T.AnimatableData == Element {
        self.animatableData = animatable.map(\.animatableData)
    }

    public init(arrayLiteral: Element...) {
        self.animatableData = arrayLiteral
    }
    
    public subscript(_ index: Int) -> Element {
        animatableData[index]
    }
}

extension AnimatableArray: AdditiveArithmetic {
    public static var zero: Self { .init(elements: []) }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(zip(lhs.animatableData, rhs.animatableData).map(+) + (lhs.count < rhs.count ? rhs.animatableData[lhs.count ..< rhs.count] : lhs.animatableData[rhs.count ..< lhs.count])
        )
    }
    
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        lhs + Self(rhs.animatableData.map { Element.zero - $0 })
    }
}

extension AnimatableArray: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        for var element in animatableData {
            element.scale(by: rhs)
        }
    }
    
    public var magnitudeSquared: Double {
        animatableData.map(\.magnitudeSquared)
            .reduce(into: 0, +=)
    }
}

//extension Array: Animatable where Element: Animatable {
//    public var animatableData: AnimatableArray<Element.AnimatableData> {
//        get {
//            .init(map(\.animatableData))
//        }
//        set {
//            update(with: newValue)
//        }
//    }
//    
//    mutating func update(with newValue: AnimatableArray<Element.AnimatableData>) {
//        for (var element, newData) in zip(self, newValue) {
//            element.animatableData = newData
//        }
//    }
//}
