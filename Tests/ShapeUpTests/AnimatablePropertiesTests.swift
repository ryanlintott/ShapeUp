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
    func publicPropertyGroupInterpolatesOnlyMatchingIDs() {
        let source = PropertyGroupFixture(id: .first, value: 10)

        let matchingTarget = PropertyGroupFixture(id: .first, value: 20)
        var matchingData = source.animatableData
        matchingData.interpolate(towards: matchingTarget.animatableData, amount: 0.5)
        var matchingResult = matchingTarget
        matchingResult.animatableData = matchingData

        #expect(matchingResult.value == 15)

        let differentTarget = PropertyGroupFixture(id: .second, value: 20)
        var differentData = source.animatableData
        differentData.interpolate(towards: differentTarget.animatableData, amount: 0.5)
        var differentResult = differentTarget
        differentResult.animatableData = differentData

        #expect(differentResult.value == 20)
    }

    @Test
    func changingBetweenDifferentCornerStylesImmediatelyUsesTargetStyle() {
        let styles: [CornerStyle] = [
            .automatic,
            .point,
            .rounded(radius: 10),
            .rounded(radius: 10, style: .continuous),
            .concave(radius: 11, concaveInset: 2),
            .straight(radius: 12, cornerStyles: [.rounded(radius: 3)]),
            .cutout(radius: 13, cornerStyles: [.concave(radius: 4, concaveInset: 1)]),
            .custom(radius: 14) {
                RelativeCorner(.rounded(radius: 5), x: 0.25, y: 0.75)
                    .moved(dx: 2, dy: 4)
            },
        ]

        for source in styles {
            for target in styles where source.name != target.name {
                for amount in [0.0, 0.5, 0.999] {
                    let interpolated = interpolatedStyle(
                        from: source,
                        to: target,
                        amount: amount
                    )

                    #expect(
                        interpolated == target,
                        "Expected \(source.name) -> \(target.name) to use the target style at \(amount)."
                    )
                }
            }
        }
    }

    @Test
    func changingPropertiesWithinSameCornerStyleInterpolatesValues() {
        let transitions: [(source: CornerStyle, target: CornerStyle, midpoint: CornerStyle)] = [
            (
                .rounded(radius: 10),
                .rounded(radius: 20),
                .rounded(radius: 15)
            ),
            (
                .rounded(radius: 10, style: .continuous),
                .rounded(radius: 20, style: .continuous),
                .rounded(radius: 15, style: .continuous)
            ),
            (
                .rounded(radius: 10, style: .circular),
                .rounded(radius: 20, style: .continuous),
                .rounded(radius: 15, style: .continuous)
            ),
            (
                .concave(radius: 10, concaveInset: 2),
                .concave(radius: 20, concaveInset: 6),
                .concave(radius: 15, concaveInset: 4)
            ),
            (
                .straight(radius: 10, cornerStyles: [.rounded(radius: 2)]),
                .straight(radius: 20, cornerStyles: [.rounded(radius: 6)]),
                .straight(radius: 15, cornerStyles: [.rounded(radius: 4), .automatic])
            ),
            (
                .cutout(radius: 10, cornerStyles: [.concave(radius: 2, concaveInset: 1)]),
                .cutout(radius: 20, cornerStyles: [.concave(radius: 6, concaveInset: 5)]),
                .cutout(
                    radius: 15,
                    cornerStyles: [.concave(radius: 4, concaveInset: 3), .automatic, .automatic]
                )
            ),
        ]

        for transition in transitions {
            let interpolated = interpolatedStyle(
                from: transition.source,
                to: transition.target,
                amount: 0.5
            )

            #expect(interpolated == transition.midpoint)
        }
    }

    @Test
    func changingNestedCornerToDifferentStyleImmediatelyUsesTargetNestedStyle() {
        let source = CornerStyle.straight(
            radius: 10,
            cornerStyles: [.rounded(radius: 10)]
        )
        let target = CornerStyle.straight(
            radius: 20,
            cornerStyles: [.concave(radius: 20, concaveInset: 6)]
        )

        let interpolated = interpolatedStyle(from: source, to: target, amount: 0.5)

        #expect(interpolated == .straight(
            radius: 15,
            cornerStyles: [.concave(radius: 20, concaveInset: 6), .automatic]
        ))
    }

    @Test
    func nestedCornerStyleIDsAreMatchedIndependently() {
        let source = CornerStyle.straight(
            radius: 10,
            cornerStyles: [
                .rounded(radius: 10),
                .rounded(radius: 20),
            ]
        )
        let target = CornerStyle.straight(
            radius: 20,
            cornerStyles: [
                .rounded(radius: 20),
                .concave(radius: 30, concaveInset: 6),
            ]
        )

        let interpolated = interpolatedStyle(from: source, to: target, amount: 0.5)

        #expect(interpolated == .straight(
            radius: 15,
            cornerStyles: [
                .rounded(radius: 15),
                .concave(radius: 30, concaveInset: 6),
            ]
        ))
    }

    @Test
    func relativeCornerUsesFiniteProjectionAndImmediatelySwitchesStyle() {
        let source = RelativeCorner(.rounded(radius: 10), x: 0, y: 0)
            .moved(dx: 0, dy: 0)
        let targetStyle = CornerStyle.custom(radius: 20) {
            RelativeCorner(.rounded(radius: 4), x: 0.25, y: 0.75)
                .moved(dx: 2, dy: 4)
        }
        let target = RelativeCorner(targetStyle, x: 1, y: 1)
            .moved(dx: 4, dy: 8)

        var data = source.animatableData
        data.interpolate(towards: target.animatableData, amount: 0.5)

        var interpolated = target
        interpolated.animatableData = data

        let point = interpolated.anchor.point(in: CGRect(x: 0, y: 0, width: 1, height: 1))
        #expect(abs(point.x - 0.5) < 1e-12)
        #expect(abs(point.y - 0.5) < 1e-12)
        #expect(interpolated.offset == Vector2(dx: 2, dy: 4))
        #expect(interpolated.style == targetStyle)
    }

    @Test
    func changingBetweenCustomCornerStylesInterpolatesSubcornerPositions() throws {
        let source = CornerStyle.custom(radius: 10) {
            RelativeCorner(x: 0, y: 0).moved(dx: 0, dy: 0)
            RelativeCorner(x: 0.5, y: 0.5).moved(dx: 2, dy: 4)
        }
        let target = CornerStyle.custom(radius: 10) {
            RelativeCorner(x: 0.5, y: 1).moved(dx: 4, dy: 8)
            RelativeCorner(x: 1, y: 1).moved(dx: 6, dy: 8)
        }

        var data = source.animatableData
        data.interpolate(towards: target.animatableData, amount: 0.5)

        var interpolated = target
        interpolated.animatableData = data

        guard case let .custom(_, relativeCorners) = interpolated else {
            Issue.record("Expected a custom corner style.")
            return
        }

        let unitRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let anchorPoints = relativeCorners.map { $0.anchor.point(in: unitRect) }
        let firstAnchorPoint = try #require(anchorPoints.first)
        let lastAnchorPoint = try #require(anchorPoints.last)
        #expect(abs(firstAnchorPoint.x - 0.25) < 1e-12)
        #expect(abs(firstAnchorPoint.y - 0.5) < 1e-12)
        #expect(abs(lastAnchorPoint.x - 0.75) < 1e-12)
        #expect(abs(lastAnchorPoint.y - 0.75) < 1e-12)
        #expect(relativeCorners.map(\.offset) == [
            Vector2(dx: 2, dy: 4),
            Vector2(dx: 4, dy: 6),
        ])
    }

    private func interpolatedStyle(
        from source: CornerStyle,
        to target: CornerStyle,
        amount: Double
    ) -> CornerStyle {
        var data = source.animatableData
        data.interpolate(towards: target.animatableData, amount: amount)

        var interpolated = target
        interpolated.animatableData = data
        return interpolated
    }

    @Test
    func cornerStyleAnimatableDataUsesRelativeCornerAnimatableData() throws {
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
        #expect(relativeCorner.style.cornerStyles == [.rounded(radius: 4)])
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

private enum PropertyGroupID: Hashable {
    case first
    case second
}

private struct PropertyGroupFixture: AnimatableProperties {
    var id: PropertyGroupID
    var value: CGFloat

    static var animatableProperties: some AnimatableProperty<Self> {
        AnimatablePropertyGroup(id: \.id) {
            \.value
        }
    }
}

private struct NestedLeaf: AnimatableProperties {
    var value: CGFloat

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
    }
}

private struct NestedBranch: AnimatableProperties {
    var value: CGFloat
    var leaf: NestedLeaf

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
        \.leaf
    }
}

private struct NestedRoot: AnimatableProperties {
    var value: CGFloat
    var branch: NestedBranch

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
        \.branch
    }
}

private struct NestedPropertiesFixture: AnimatableProperties {
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

private struct AnimatableValueFixture: AnimatableProperties {
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

private struct DualConformanceFixture: AnimatableProperties {
    var value: DualConformanceValue

    static var animatableProperties: some AnimatableProperty<Self> {
        \.value
    }
}
