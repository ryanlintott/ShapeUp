//
//  AnimatableDictionaryTests.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-06-15.
//

import ShapeUp
import SwiftUI
import Testing

struct AnimatableDictionaryTests {
    @Test
    func vectorArithmeticValuesUpdateOnlyMatchingExistingKeys() {
        var values = [
            1: Vector2(dx: 1, dy: 2),
            3: Vector2(dx: 3, dy: 4)
        ]
        
        values.animatableDictionary = AnimatableDictionary([
            1: Vector2(dx: 10, dy: 20),
            2: Vector2(dx: 30, dy: 40)
        ])

        #expect(values == [
            1: Vector2(dx: 10, dy: 20),
            3: Vector2(dx: 3, dy: 4)
        ])
    }

    @Test
    func animatableValuesUpdateOnlyMatchingExistingKeys() {
        var values = [
            1: AnimatedValue(value: 1),
            3: AnimatedValue(value: 3)
        ]

        values.animatableValueDictionary = AnimatableDictionary([
            1: 10,
            2: 20
        ])

        #expect(values == [
            1: AnimatedValue(value: 10),
            3: AnimatedValue(value: 3)
        ])
    }
}

private struct AnimatedValue: Animatable, Equatable {
    var value: CGFloat

    var animatableData: CGFloat {
        get { value }
        set { value = newValue }
    }
}

private struct DualConformingValue: Animatable, VectorArithmetic {
    var value: CGFloat

    static let zero = Self(value: 0)

    var animatableData: Self {
        get { self }
        set { self = newValue }
    }

    var magnitudeSquared: Double {
        value.magnitudeSquared
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        Self(value: lhs.value + rhs.value)
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        Self(value: lhs.value - rhs.value)
    }

    mutating func scale(by rhs: Double) {
        value.scale(by: rhs)
    }
}
