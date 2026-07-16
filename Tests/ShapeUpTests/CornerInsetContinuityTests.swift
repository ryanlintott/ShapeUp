//
//  CornerInsetContinuityTests.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-07-14.
//

@testable import ShapeUp
import SwiftUI
import Testing

struct CornerInsetContinuityTests {
    typealias StyleKind = CornerDimensionsPathTests.StyleKind

    private struct CornerPoints: CustomTestStringConvertible, Sendable {
        let name: String
        let previous: CGPoint
        let next: CGPoint

        var testDescription: String { name }

        static let singularitySamples: [Self] = [
            .init(
                name: "before zero",
                previous: CGPoint(x: 100, y: -0.0001),
                next: CGPoint(x: 100, y: 0.0001)
            ),
            .init(
                name: "zero",
                previous: CGPoint(x: 100, y: 0),
                next: CGPoint(x: 100, y: 0)
            ),
            .init(
                name: "after zero",
                previous: CGPoint(x: 100, y: 0.0001),
                next: CGPoint(x: 100, y: -0.0001)
            ),
            .init(
                name: "before straight",
                previous: CGPoint(x: -100, y: -0.0001),
                next: CGPoint(x: 100, y: -0.0001)
            ),
            .init(
                name: "straight",
                previous: CGPoint(x: -100, y: 0),
                next: CGPoint(x: 100, y: 0)
            ),
            .init(
                name: "after straight",
                previous: CGPoint(x: -100, y: 0.0001),
                next: CGPoint(x: 100, y: 0.0001)
            )
        ]
    }

    struct StraightCrossing: CustomTestStringConvertible, Sendable {
        let name: String
        let inset: CGFloat
        let angles: [CGFloat]

        var testDescription: String { name }

        static let all: [Self] = [
            .init(name: "straight inset", inset: 12, angles: [179.9999, 180, 180.0001]),
            .init(name: "straight outset", inset: -12, angles: [179.9999, 180, 180.0001])
        ]
    }

    @Test(
        "Insets stay finite for every style around 0 and 180 degrees",
        arguments: StyleKind.allCases,
        [CGFloat(12), -12]
    )
    func insetsStayFinite(styleKind: StyleKind, inset: CGFloat) {
        let corner = Corner(
            styleKind.style(radius: .mixed(absolute: 10, relative: 0.25)),
            point: CGPoint.zero
        )

        for points in CornerPoints.singularitySamples {
            let insetCorner = corner
                .dimensions(previousPoint: points.previous, nextPoint: points.next)
                .corner(inset: inset)
            let insetDimensions = insetCorner.dimensions(
                previousPoint: points.previous,
                nextPoint: points.next
            )
            let path = path(for: insetDimensions)

            #expect(insetCorner.point.isFinite)
            #expect(insetCorner.style.finiteScalars.allSatisfy { $0.isFinite })
            #expect(insetDimensions.finiteInsetScalars.allSatisfy { $0.isFinite })
            #expect(path.insetPoints.allSatisfy { $0.isFinite })
            #expect(path.hasFiniteInsetBounds)
        }
    }

    @Test(
        "Complete inset paths stay continuous through 180 degrees",
        arguments: StyleKind.allCases,
        StraightCrossing.all
    )
    func completeInsetPathsStayContinuousThroughStraightAngle(
        styleKind: StyleKind,
        crossing: StraightCrossing
    ) {
        let bounds = crossing.angles.map { angle in
            animatedCorners(angleDegrees: angle, style: styleKind.simpleStyle)
                .inset(by: crossing.inset)
                .path()
                .boundingRect
        }

        #expect(bounds[0].isApproximatelyEqual(to: bounds[1], tolerance: 0.01))
        #expect(bounds[2].isApproximatelyEqual(to: bounds[1], tolerance: 0.01))
    }

    @Test(
        "A zero-degree corner remains unchanged when inset",
        arguments: StyleKind.allCases,
        [CGFloat(12), -12]
    )
    func exactZeroRemainsUnchanged(styleKind: StyleKind, inset: CGFloat) {
        let corner = Corner(styleKind.simpleStyle, point: CGPoint.zero)
        let dimensions = corner.dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(x: 100, y: 0)
        )

        let insetCorner = dimensions.corner(inset: inset)

        #expect(insetCorner == corner)
        #expect(insetCorner.style.finiteScalars.allSatisfy { $0.isFinite })
    }

    @Test(
        "A 180-degree corner translates without changing its style",
        arguments: StyleKind.allCases,
        [CGFloat(12), -12]
    )
    func exactStraightTranslatesStyle(styleKind: StyleKind, inset: CGFloat) {
        let corner = Corner(styleKind.simpleStyle, point: CGPoint.zero)
        let dimensions = corner.dimensions(
            previousPoint: CGPoint(x: -100, y: 0),
            nextPoint: CGPoint(x: 100, y: 0)
        )
        let insetCorner = dimensions.corner(inset: inset)

        #expect(insetCorner.point.isApproximatelyEqual(
            to: CGPoint(x: 0, y: inset),
            tolerance: 1e-10
        ))
        #expect(insetCorner.style == corner.style)
    }

    @Test("Ordinary 90-degree insets retain their established geometry")
    func ordinaryInsetGeometryIsUnchanged() {
        let previous = CGPoint(x: 0, y: 100)
        let next = CGPoint(x: 100, y: 0)
        let inset: CGFloat = 10

        let rounded = Corner(.rounded(radius: 20), point: CGPoint.zero)
            .dimensions(previousPoint: previous, nextPoint: next)
            .corner(inset: inset)
        let concave = Corner(.concave(radius: 20), point: CGPoint.zero)
            .dimensions(previousPoint: previous, nextPoint: next)
            .corner(inset: inset)

        #expect(rounded.point.isApproximatelyEqual(to: CGPoint(x: 10, y: 10), tolerance: 1e-10))
        #expect(rounded.style == .rounded(radius: 10))
        #expect(concave.point.isApproximatelyEqual(to: CGPoint(x: 10, y: 10), tolerance: 1e-10))
        #expect(concave.style == .concave(radius: 20, concaveInset: 10))
    }

    private func path(for dimensions: Corner.Dimensions) -> Path {
        var path = Path()
        dimensions.addCornerShape(to: &path, moveToStart: true)
        return path
    }

    private func animatedCorners(angleDegrees: CGFloat, style: CornerStyle) -> [Corner] {
        let center = CGPoint.zero
        let armLength: CGFloat = 100
        let halfAngle = Angle.degrees(angleDegrees / 2)
        let point0 = center.moved(Vector2(magnitude: armLength, direction: halfAngle))
        let point2 = center.moved(Vector2(magnitude: armLength, direction: -halfAngle))

        return [
            Corner(x: 160, y: -120),
            Corner(x: 160, y: 120),
            Corner(point: point0),
            Corner(style, point: center),
            Corner(point: point2)
        ]
    }
}

private extension CornerStyle {
    var finiteScalars: [CGFloat] {
        switch self {
        case .automatic, .point:
            []
        case let .rounded(radius), let .straight(radius, _), let .cutout(radius, _):
            [radius.value(using: 100)] + cornerStyles.flatMap(\.finiteScalars)
        case let .concave(radius, concaveInset):
            [radius.value(using: 100), concaveInset]
        case let .custom(radius, relativeCorners):
            [radius.value(using: 100)] + relativeCorners.flatMap { corner in
                let point = corner.corner(in: CGRect(x: 0, y: 0, width: 100, height: 100)).point
                return [point.x, point.y] + corner.style.finiteScalars
            }
        }
    }
}

private extension Corner.Dimensions {
    var finiteInsetScalars: [CGFloat] {
        [
            angle.radians,
            maxCutLength,
            maxRadius,
            absoluteRadius,
            cutLength,
            concaveInset,
            concaveRadius
        ]
    }
}

private extension Path {
    var insetPoints: [CGPoint] {
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

    var hasFiniteInsetBounds: Bool {
        let bounds = boundingRect
        return bounds.isNull || [
            bounds.minX,
            bounds.minY,
            bounds.width,
            bounds.height
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

private extension CGRect {
    func isApproximatelyEqual(to other: Self, tolerance: CGFloat) -> Bool {
        if isNull || other.isNull {
            return isNull == other.isNull
        }

        return abs(minX - other.minX) <= tolerance
            && abs(minY - other.minY) <= tolerance
            && abs(width - other.width) <= tolerance
            && abs(height - other.height) <= tolerance
    }
}
