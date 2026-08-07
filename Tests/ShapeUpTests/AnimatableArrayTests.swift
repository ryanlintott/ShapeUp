//
//  AnimatableArrayTests.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-07.
//

import ShapeUp
import SwiftUI
import Testing

struct AnimatableArrayTests {
    @Test
    func vectorArithmeticElementsUpdateOnlyMatchingExistingIndices() {
        var values = [
            Vector2(dx: 1, dy: 2),
            Vector2(dx: 3, dy: 4)
        ]

        values.animatableArray = AnimatableArray([
            Vector2(dx: 10, dy: 20)
        ])

        #expect(values == [
            Vector2(dx: 10, dy: 20),
            Vector2(dx: 3, dy: 4)
        ])
        #expect(values.animatableArray.wrappedValue == values)
    }

    @Test
    func animatableElementsUpdateOnlyMatchingExistingIndices() {
        var values = [
            AnimatedValue(value: 1),
            AnimatedValue(value: 3)
        ]

        values.animatableValueArray = AnimatableArray([10])

        #expect(values == [
            AnimatedValue(value: 10),
            AnimatedValue(value: 3)
        ])
        #expect(values.animatableValueArray.wrappedValue == values.map(\.animatableData))
    }
}

private struct AnimatedValue: Animatable, Equatable {
    var value: CGFloat

    var animatableData: CGFloat {
        get { value }
        set { value = newValue }
    }
}
