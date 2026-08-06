//
//  AnimatablePropertiesTests.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-04.
//

import ShapeUp
import SwiftUI
import Testing

struct AnimatablePropertiesTests {
    @Test
    func cornerStyleAnimatableDataUsesItsDeclaredFields() {
        var style = CornerStyle.custom(radius: 10) {
            RelativeCorner(.rounded(radius: 5), x: 0.25, y: 0.75)
        }

        var data = style.animatableData
        data.scale(by: 2)
        style.animatableData = data

        #expect(style.radius == 20)
        #expect(style.cornerStyles == [.rounded(radius: 10)])
    }

    @Test
    func relativeCornerAnimatableDataUsesItsDeclaredFields() {
        var corner = RelativeCorner(
            .custom(radius: 10) {
                RelativeCorner(.rounded(radius: 5), x: 0.25, y: 0.75)
            },
            x: 0.5,
            y: 0.5
        )

        var data = corner.animatableData
        data.scale(by: 2)
        corner.animatableData = data

        #expect(corner.style.radius == 20)
        #expect(corner.style.cornerStyles == [.rounded(radius: 10)])
    }

    @Test
    func recursiveFieldsAnimateOneAdditionalLevelOnly() {
        var value = RecursiveNode(
            value: 1,
            children: [
                .init(
                    value: 2,
                    children: [.init(value: 3)]
                )
            ]
        )

        var data = value.animatableData
        data.scale(by: 10)
        value.animatableData = data

        #expect(value.value == 10)
        #expect(value.children.first?.value == 20)
        #expect(value.children.first?.children.first?.value == 3)
    }

    @Test
    func heterogeneousRecursiveFieldsReadAndWriteDirectData() {
        var value = RecursiveFixture(
            value: 1,
            child: .init(value: 2),
            optionalChild: .init(value: 2.5),
            children: [.init(value: 3), .init(value: 4)],
            keyedChildren: [5: .init(value: 5)]
        )

        var data = value.animatableData
        data.scale(by: 10)
        value.animatableData = data

        #expect(value.value == 10)
        #expect(value.child.value == 20)
        #expect(value.optionalChild?.value == 25)
        #expect(value.children.map(\.value) == [30, 40])
        #expect(value.keyedChildren[5]?.value == 50)
    }

    @Test
    func absentOptionalRecursiveFieldRemainsAbsent() {
        var value = RecursiveFixture(
            value: 1,
            child: .init(value: 2),
            optionalChild: nil,
            children: [],
            keyedChildren: [:]
        )

        var data = value.animatableData
        data.scale(by: 10)
        value.animatableData = data

        #expect(value.optionalChild == nil)
    }

    @Test
    func directAnimatableFieldUsesItsAnimatableData() {
        var value = AnimatableValueFixture(value: .init(value: 2))

        var data = value.animatableData
        data.scale(by: 10)
        value.animatableData = data

        #expect(value.value.value == 20)
    }

    @Test
    func directFieldPrefersVectorArithmeticWhenTypeIsAlsoAnimatable() {
        var value = DualConformanceFixture(
            value: .init(vectorValue: 2, animatableValue: 7)
        )

        var data = value.animatableData
        data.scale(by: 10)
        value.animatableData = data

        #expect(value.value.vectorValue == 20)
        #expect(value.value.animatableValue == 70)
    }
}

private struct RecursiveNode: AnimatableByProperty, Equatable {
    var value: CGFloat
    var children: [Self] = []

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
    }

    static var recursiveAnimatableProperties: some AnimatableProperty<Self> {
        \.children
    }
}

private struct RecursiveFixture: AnimatableByProperty {
    var value: CGFloat
    var child: RecursiveNode
    var optionalChild: RecursiveNode?
    var children: [RecursiveNode]
    var keyedChildren: [Int: RecursiveNode]

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
    }

    static var recursiveAnimatableProperties: some AnimatableProperty<Self> {
        \.child
        \.optionalChild
        \.children
        \.keyedChildren
    }
}

private struct AnimatableValue: Animatable {
    var value: CGFloat

    var animatableData: CGFloat {
        get { value }
        set { value = newValue }
    }
}

private struct AnimatableValueFixture: AnimatableByProperty {
    var value: AnimatableValue

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
    }

    static var recursiveAnimatableProperties: some AnimatableProperty<Self> { }
}

private struct DualConformanceValue: VectorArithmetic, Animatable {
    var vectorValue: CGFloat
    var animatableValue: Double

    static var zero: Self {
        .init(vectorValue: 0, animatableValue: 0)
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        .init(
            vectorValue: lhs.vectorValue + rhs.vectorValue,
            animatableValue: lhs.animatableValue + rhs.animatableValue
        )
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        .init(
            vectorValue: lhs.vectorValue - rhs.vectorValue,
            animatableValue: lhs.animatableValue - rhs.animatableValue
        )
    }

    mutating func scale(by rhs: Double) {
        vectorValue *= rhs
        animatableValue *= rhs
    }

    var magnitudeSquared: Double {
        (vectorValue * vectorValue) + (animatableValue * animatableValue)
    }

    var animatableData: Double {
        get { animatableValue }
        set { animatableValue = newValue }
    }
}

private struct DualConformanceFixture: AnimatableByProperty {
    var value: DualConformanceValue

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
    }

    static var recursiveAnimatableProperties: some AnimatableProperty<Self> { }
}
