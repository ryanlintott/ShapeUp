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
    func cornerStyleAnimatableDataUsesFiniteRelativeCornerProjections() throws {
        var style = CornerStyle.custom(radius: 10) {
            RelativeCorner(
                .custom(radius: 5) {
                    RelativeCorner(.rounded(radius: 2), x: 0.1, y: 0.2)
                },
                x: 0.25,
                y: 0.75
            )
            .moved(dx: 3, dy: 4)
        }

        var data = style.animatableData
        data.scale(by: 2)
        style.animatableData = data

        #expect(style.radius == 20)

        guard case let .custom(_, relativeCorners) = style else {
            Issue.record("Expected a custom corner style.")
            return
        }

        let relativeCorner = try #require(relativeCorners.first)
        let anchorPoint = relativeCorner.anchor.point(in: CGRect(x: 0, y: 0, width: 1, height: 1))
        #expect(abs(anchorPoint.x - 0.5) < 1e-12)
        #expect(abs(anchorPoint.y - 1.5) < 1e-12)
        #expect(relativeCorner.offset == Vector2(dx: 6, dy: 8))
        #expect(relativeCorner.style.radius == 10)
        #expect(relativeCorner.style.cornerStyles == [.rounded(radius: 2)])
    }

    @Test
    func relativeCornerAnimatableDataUsesFiniteCornerStyleProjections() throws {
        var corner = RelativeCorner(
            .custom(radius: 10) {
                RelativeCorner(
                    .custom(radius: 5) {
                        RelativeCorner(.rounded(radius: 2), x: 0.1, y: 0.2)
                    },
                    x: 0.25,
                    y: 0.75
                )
                .moved(dx: 3, dy: 4)
            },
            x: 0.5,
            y: 0.5
        )
        .moved(dx: 6, dy: 8)

        var data = corner.animatableData
        data.scale(by: 2)
        corner.animatableData = data

        let cornerAnchorPoint = corner.anchor.point(in: CGRect(x: 0, y: 0, width: 1, height: 1))
        #expect(abs(cornerAnchorPoint.x - 1) < 1e-12)
        #expect(abs(cornerAnchorPoint.y - 1) < 1e-12)
        #expect(corner.offset == Vector2(dx: 12, dy: 16))
        #expect(corner.style.radius == 20)

        guard case let .custom(_, relativeCorners) = corner.style else {
            Issue.record("Expected a custom corner style.")
            return
        }

        let relativeCorner = try #require(relativeCorners.first)
        let relativeCornerAnchorPoint = relativeCorner.anchor.point(in: CGRect(x: 0, y: 0, width: 1, height: 1))
        #expect(abs(relativeCornerAnchorPoint.x - 0.5) < 1e-12)
        #expect(abs(relativeCornerAnchorPoint.y - 1.5) < 1e-12)
        #expect(relativeCorner.offset == Vector2(dx: 6, dy: 8))
        #expect(relativeCorner.style.radius == 10)
        #expect(relativeCorner.style.cornerStyles == [.rounded(radius: 2)])
    }

    @Test
    func nestedAnimatablePropertiesTraverseEveryDeclaredLevel() {
        var value = NestedRoot(
            value: 1,
            branch: .init(
                value: 2,
                leaf: .init(value: 3)
            )
        )

        var data = value.animatableData
        data.scale(by: 10)
        value.animatableData = data

        #expect(value.value == 10)
        #expect(value.branch.value == 20)
        #expect(value.branch.leaf.value == 30)
    }

    @Test
    func heterogeneousNestedPropertiesReadAndWriteAnimatableData() {
        var value = NestedPropertiesFixture(
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
    func absentOptionalNestedPropertyRemainsAbsent() {
        var value = NestedPropertiesFixture(
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

private struct NestedLeaf: AnimatableByProperty {
    var value: CGFloat

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
    }
}

private struct NestedBranch: AnimatableByProperty {
    var value: CGFloat
    var leaf: NestedLeaf

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
        \.leaf
    }
}

private struct NestedRoot: AnimatableByProperty {
    var value: CGFloat
    var branch: NestedBranch

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
        \.branch
    }
}

private struct NestedPropertiesFixture: AnimatableByProperty {
    var value: CGFloat
    var child: NestedLeaf
    var optionalChild: NestedLeaf?
    var children: [NestedLeaf]
    var keyedChildren: [Int: NestedLeaf]

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
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
}
