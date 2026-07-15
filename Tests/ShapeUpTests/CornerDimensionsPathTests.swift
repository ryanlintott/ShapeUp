//
//  CornerDimensionsPathTests.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-07-13.
//

import ShapeUp
import SwiftUI
import Testing

struct CornerDimensionsPathTests {
    enum StyleKind: String, CaseIterable, CustomTestStringConvertible, Sendable {
        case point
        case rounded
        case concave
        case straight
        case cutout
        case custom

        var testDescription: String { rawValue }

        func style(radius: RelatableValue) -> CornerStyle {
            switch self {
            case .point:
                .point
            case .rounded:
                .rounded(radius: radius)
            case .concave:
                .concave(radius: radius)
            case .straight:
                .straight(
                    radius: radius,
                    cornerStyles: [.rounded(radius: .relative(0.25)), .point]
                )
            case .cutout:
                .cutout(
                    radius: radius,
                    cornerStyles: [
                        .rounded(radius: .relative(0.25)),
                        .cutout(radius: .relative(0.25)),
                        .point
                    ]
                )
            case .custom:
                .custom(
                    radius: radius,
                    relativeCorners: [
                        RelativeCorner(.rounded(radius: .relative(0.25)), x: 0, y: 0),
                        RelativeCorner(.cutout(radius: .relative(0.25)), x: 0.25, y: 1),
                        RelativeCorner(.straight(radius: .relative(0.25)), x: 1, y: 1)
                    ]
                )
            }
        }
    }

    struct RadiusCase: CustomTestStringConvertible, Sendable {
        let name: String
        let value: RelatableValue

        var testDescription: String { name }

        static let all: [Self] = [
            .init(name: "absolute", value: .absolute(10)),
            .init(name: "relative", value: .relative(0.5)),
            .init(name: "mixed", value: .mixed(absolute: 10, relative: 0.25))
        ]
    }

    private struct CornerPoints: Sendable {
        let previous: CGPoint
        let next: CGPoint

        static let animationSamples: [Self] = [
            // Points 0 and 2 exchange positions through a zero-degree corner.
            .init(previous: CGPoint(x: 100, y: -0.0001), next: CGPoint(x: 100, y: 0.0001)),
            .init(previous: CGPoint(x: 100, y: 0), next: CGPoint(x: 100, y: 0)),
            .init(previous: CGPoint(x: 100, y: 0.0001), next: CGPoint(x: 100, y: -0.0001)),
            // The two segments cross through a straight corner.
            .init(previous: CGPoint(x: -100, y: -0.0001), next: CGPoint(x: 100, y: -0.0001)),
            .init(previous: CGPoint(x: -100, y: 0), next: CGPoint(x: 100, y: 0)),
            .init(previous: CGPoint(x: -100, y: 0.0001), next: CGPoint(x: 100, y: 0.0001))
        ]
    }

    struct OrdinaryArcCase: CustomTestStringConvertible, Sendable {
        let name: String
        let previous: CGPoint
        let next: CGPoint
        let expectedBounds: CGRect

        var testDescription: String { name }

        static let all: [Self] = [
            .init(
                name: "non-reflex",
                previous: CGPoint(x: 0, y: 100),
                next: CGPoint(x: 100, y: 0),
                expectedBounds: CGRect(x: 0, y: 0, width: 50, height: 50)
            ),
            .init(
                name: "reflex",
                previous: CGPoint(x: 0, y: -100),
                next: CGPoint(x: 100, y: 0),
                expectedBounds: CGRect(x: 0, y: -50, width: 50, height: 50)
            )
        ]
    }

    @Test(
        "Animated corner paths stay finite around 0 and 180 degrees",
        arguments: StyleKind.allCases,
        RadiusCase.all
    )
    func animatedCornerPathsStayFinite(styleKind: StyleKind, radius: RadiusCase) {
        let corner = Corner(styleKind.style(radius: radius.value), point: CGPoint.zero)

        let paths = CornerPoints.animationSamples.map { points in
            path(for: corner.dimensions(previousPoint: points.previous, nextPoint: points.next))
        }

        for (points, path) in zip(CornerPoints.animationSamples, paths) {
            let dimensions = corner.dimensions(
                previousPoint: points.previous,
                nextPoint: points.next
            )

            #expect(dimensions.finiteScalars.allSatisfy { $0.isFinite })
            #expect(dimensions.finitePoints.allSatisfy { $0.isFinite })
            #expect(path.points.allSatisfy { $0.isFinite })
            #expect(path.finiteBounds)
        }

        #expect(paths[0].boundingRect.isApproximatelyEqual(to: paths[1].boundingRect, tolerance: 0.001))
        #expect(paths[2].boundingRect.isApproximatelyEqual(to: paths[1].boundingRect, tolerance: 0.001))
        #expect(paths[3].boundingRect.isApproximatelyEqual(to: paths[4].boundingRect, tolerance: 0.001))
        #expect(paths[5].boundingRect.isApproximatelyEqual(to: paths[4].boundingRect, tolerance: 0.001))
    }

    @Test("Effective cut length is continuous through zero degrees", arguments: RadiusCase.all)
    func cutLengthIsContinuousThroughZeroDegrees(radius: RadiusCase) {
        let corner = Corner(.rounded(radius: radius.value), point: CGPoint.zero)
        let before = corner.dimensions(
            previousPoint: CGPoint(x: 100, y: -0.0001),
            nextPoint: CGPoint(x: 100, y: 0.0001)
        )
        let exact = corner.dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(x: 100, y: 0)
        )
        let after = corner.dimensions(
            previousPoint: CGPoint(x: 100, y: 0.0001),
            nextPoint: CGPoint(x: 100, y: -0.0001)
        )

        let expectedCutLength: CGFloat = switch radius.name {
        case "relative": 50
        default: 100
        }

        #expect(abs(exact.cutLength - expectedCutLength) < 1e-10)
        #expect(before.cutLength.isApproximatelyEqual(to: exact.cutLength, tolerance: 1e-8))
        #expect(after.cutLength.isApproximatelyEqual(to: exact.cutLength, tolerance: 1e-8))
        #expect(before.cornerStart.isApproximatelyEqual(to: exact.cornerStart, tolerance: 0.0002))
        #expect(after.cornerStart.isApproximatelyEqual(to: exact.cornerStart, tolerance: 0.0002))
        #expect(before.cornerEnd.isApproximatelyEqual(to: exact.cornerEnd, tolerance: 0.0002))
        #expect(after.cornerEnd.isApproximatelyEqual(to: exact.cornerEnd, tolerance: 0.0002))
    }

    @Test("Effective cut length is continuous through 180 degrees", arguments: RadiusCase.all)
    func cutLengthIsContinuousThroughStraightAngle(radius: RadiusCase) {
        let corner = Corner(.rounded(radius: radius.value), point: CGPoint.zero)
        let before = corner.dimensions(
            previousPoint: CGPoint(x: -100, y: -0.0001),
            nextPoint: CGPoint(x: 100, y: -0.0001)
        )
        let exact = corner.dimensions(
            previousPoint: CGPoint(x: -100, y: 0),
            nextPoint: CGPoint(x: 100, y: 0)
        )
        let after = corner.dimensions(
            previousPoint: CGPoint(x: -100, y: 0.0001),
            nextPoint: CGPoint(x: 100, y: 0.0001)
        )

        let expectedCutLength: CGFloat = switch radius.name {
        case "absolute": 0
        case "relative": 50
        default: 25
        }

        #expect(abs(exact.cutLength - expectedCutLength) < 1e-10)
        #expect(before.cutLength.isApproximatelyEqual(to: exact.cutLength, tolerance: 0.00002))
        #expect(after.cutLength.isApproximatelyEqual(to: exact.cutLength, tolerance: 0.00002))
        #expect(before.cornerStart.isApproximatelyEqual(to: exact.cornerStart, tolerance: 0.0002))
        #expect(after.cornerStart.isApproximatelyEqual(to: exact.cornerStart, tolerance: 0.0002))
        #expect(before.cornerEnd.isApproximatelyEqual(to: exact.cornerEnd, tolerance: 0.0002))
        #expect(after.cornerEnd.isApproximatelyEqual(to: exact.cornerEnd, tolerance: 0.0002))
    }

    @Test("Every style uses its analytic zero-degree path", arguments: StyleKind.allCases)
    func exactZeroDegreePathUsesStyleLimit(styleKind: StyleKind) {
        let corner = Corner(styleKind.simpleStyle, point: CGPoint.zero)
        let dimensions = corner.dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(x: 100, y: 0)
        )

        var expected = Path()
        switch styleKind {
        case .point:
            expected.move(to: .zero)
        case .rounded:
            expected.move(to: CGPoint(x: 50, y: 0))
        case .concave:
            expected.move(to: CGPoint(x: 50, y: 0))
        case .cutout:
            expected.move(to: CGPoint(x: 50, y: 0))
            expected.addLine(to: CGPoint(x: 100, y: 0))
            expected.addLine(to: CGPoint(x: 50, y: 0))
        case .straight:
            expected.move(to: CGPoint(x: 50, y: 0))
            expected.addLine(to: CGPoint(x: 50, y: 0))
        case .custom:
            expected.move(to: CGPoint(x: 50, y: 0))
            expected.addLine(to: CGPoint(x: 87.5, y: 0))
            expected.addLine(to: CGPoint(x: 50, y: 0))
        }

        #expect(dimensions.angle.degrees == 0)
        #expect(path(for: dimensions) == expected)
    }

    @Test("Every style uses its analytic 180-degree path", arguments: StyleKind.allCases)
    func exactStraightPathUsesStyleLimit(styleKind: StyleKind) {
        let corner = Corner(styleKind.simpleStyle, point: CGPoint.zero)
        let dimensions = corner.dimensions(
            previousPoint: CGPoint(x: -100, y: 0),
            nextPoint: CGPoint(x: 100, y: 0)
        )

        var expected = Path()
        switch styleKind {
        case .point:
            expected.move(to: .zero)
        case .rounded, .concave, .straight:
            expected.move(to: CGPoint(x: -50, y: 0))
            expected.addLine(to: CGPoint(x: 50, y: 0))
        case .cutout:
            expected.move(to: CGPoint(x: -50, y: 0))
            expected.addLine(to: .zero)
            expected.addLine(to: CGPoint(x: 50, y: 0))
        case .custom:
            expected.move(to: CGPoint(x: -50, y: 0))
            expected.addLine(to: CGPoint(x: 12.5, y: 0))
            expected.addLine(to: CGPoint(x: 50, y: 0))
        }

        #expect(dimensions.angle.degrees == 180)
        #expect(path(for: dimensions) == expected)
    }

    @Test(
        "Ordinary rounded and concave arcs retain their endpoints and orientation",
        arguments: [StyleKind.rounded, .concave],
        OrdinaryArcCase.all
    )
    func ordinaryArcsRetainGeometry(styleKind: StyleKind, arc: OrdinaryArcCase) throws {
        let corner = Corner(styleKind.simpleStyle, point: CGPoint.zero)
        let dimensions = corner.dimensions(previousPoint: arc.previous, nextPoint: arc.next)
        let path = path(for: dimensions)
        let firstPoint = try #require(path.points.first)
        let finalPoint = try #require(path.currentPoint)

        #expect(firstPoint.isApproximatelyEqual(to: dimensions.cornerStart, tolerance: 1e-10))
        #expect(finalPoint.isApproximatelyEqual(to: dimensions.cornerEnd, tolerance: 1e-10))
        #expect(path.boundingRect.isApproximatelyEqual(to: arc.expectedBounds, tolerance: 1e-10))
    }

    private func path(for dimensions: Corner.Dimensions) -> Path {
        var path = Path()
        dimensions.addCornerShape(to: &path, moveToStart: true)
        return path
    }
}

extension CornerDimensionsPathTests.StyleKind {
    var simpleStyle: CornerStyle {
        let radius = RelatableValue.relative(0.5)
        return switch self {
        case .point:
            .point
        case .rounded:
            .rounded(radius: radius)
        case .concave:
            .concave(radius: radius)
        case .straight:
            .straight(radius: radius)
        case .cutout:
            .cutout(radius: radius)
        case .custom:
            .custom(
                radius: radius,
                relativeCorners: [
                    RelativeCorner(x: 0, y: 0),
                    RelativeCorner(x: 0.25, y: 1),
                    RelativeCorner(x: 1, y: 1)
                ]
            )
        }
    }
}

private extension Corner.Dimensions {
    var finiteScalars: [CGFloat] {
        [
            angle.radians,
            reflexMultiplier,
            halvedNonReflexAngle.radians,
            halvedRadiusAngle.radians,
            maxCutLength,
            maxRadius,
            absoluteRadius,
            cutLength,
            concaveInset,
            concaveRadius
        ]
    }

    var finitePoints: [CGPoint] {
        [
            corner.point,
            previousPoint,
            nextPoint,
            cornerStart,
            cornerEnd,
            radiusCenter,
            cutoutPoint,
            concaveStart,
            concaveEnd,
            concaveRadiusCenter
        ].compactMap { $0 }
    }
}

private extension Path {
    var points: [CGPoint] {
        var points: [CGPoint] = []
        forEach { element in
            switch element {
            case let .move(to: point), let .line(to: point):
                points.append(point)
            case let .quadCurve(to: point, control: control):
                points.append(contentsOf: [point, control])
            case let .curve(to: point, control1: control1, control2: control2):
                points.append(contentsOf: [point, control1, control2])
            case .closeSubpath:
                break
            }
        }
        return points
    }

    var finiteBounds: Bool {
        let bounds = boundingRect
        return bounds.isNull || [
            bounds.origin.x,
            bounds.origin.y,
            bounds.size.width,
            bounds.size.height
        ].allSatisfy(\.isFinite)
    }
}

private extension CGPoint {
    var isFinite: Bool {
        x.isFinite && y.isFinite
    }

    func isApproximatelyEqual(to other: Self, tolerance: CGFloat) -> Bool {
        abs(x - other.x) <= tolerance && abs(y - other.y) <= tolerance
    }
}

private extension CGFloat {
    func isApproximatelyEqual(to other: Self, tolerance: Self) -> Bool {
        abs(self - other) <= tolerance
    }
}

private extension CGRect {
    func isApproximatelyEqual(to other: Self, tolerance: CGFloat) -> Bool {
        if isNull || other.isNull {
            return isNull == other.isNull
        }

        return origin.isApproximatelyEqual(to: other.origin, tolerance: tolerance)
            && width.isApproximatelyEqual(to: other.width, tolerance: tolerance)
            && height.isApproximatelyEqual(to: other.height, tolerance: tolerance)
    }
}
