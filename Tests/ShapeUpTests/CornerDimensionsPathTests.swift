//
//  CornerDimensionsPathTests.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-07-13.
//

@testable import ShapeUp
import SwiftUI
import Testing

struct CornerDimensionsPathTests {
    enum StyleKind: String, CaseIterable, CustomTestStringConvertible, Sendable {
        case automatic
        case point
        case rounded
        case roundedContinuous
        case concave
        case straight
        case cutout
        case custom

        var testDescription: String { rawValue }

        func style(radius: RelatableValue) -> CornerStyle {
            switch self {
            case .automatic:
                .automatic
            case .point:
                .point
            case .rounded:
                .rounded(radius: radius)
            case .roundedContinuous:
                .rounded(radius: radius, style: .continuous)
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

    struct ContinuousCornerAngleCase: CustomTestStringConvertible, Sendable {
        let degrees: CGFloat
        let reflex: Bool

        var testDescription: String {
            "\(degrees) degrees \(reflex ? "reflex" : "non-reflex")"
        }

        static let all: [Self] = [CGFloat(1), 15, 30, 60, 89, 91, 120, 150, 179]
            .flatMap { degrees in
                [
                    .init(degrees: degrees, reflex: false),
                    .init(degrees: degrees, reflex: true)
                ]
            }

        var previous: CGPoint { CGPoint(x: 100, y: 0) }

        var next: CGPoint {
            let angle = Angle.degrees(degrees * (reflex ? -1 : 1))
            return CGPoint(
                x: 100 * cos(angle.radians),
                y: 100 * sin(angle.radians)
            )
        }
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

    @Test(
        "Effective cut length is continuous through zero degrees",
        arguments: RadiusCase.all,
        [CornerStyle.RoundingStyle.circular, .continuous]
    )
    func cutLengthIsContinuousThroughZeroDegrees(
        radius: RadiusCase,
        roundingStyle: CornerStyle.RoundingStyle
    ) {
        let corner = Corner(
            .rounded(radius: radius.value, style: roundingStyle),
            point: CGPoint.zero
        )
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

        let cutLengthMultiplier = roundingStyle == .continuous
            ? Corner.Dimensions.continuousCutLengthMultiplier(for: .zero)
            : 1
        let expectedCutLength: CGFloat = switch radius.name {
        case "relative": 50 * cutLengthMultiplier
        default: 100
        }

        #expect(abs(exact.cutLength - expectedCutLength) < 1e-10)
        #expect(before.cutLength.isApproximatelyEqual(to: exact.cutLength, tolerance: 0.0001))
        #expect(after.cutLength.isApproximatelyEqual(to: exact.cutLength, tolerance: 0.0001))
        #expect(before.cornerStart.isApproximatelyEqual(to: exact.cornerStart, tolerance: 0.0002))
        #expect(after.cornerStart.isApproximatelyEqual(to: exact.cornerStart, tolerance: 0.0002))
        #expect(before.cornerEnd.isApproximatelyEqual(to: exact.cornerEnd, tolerance: 0.0002))
        #expect(after.cornerEnd.isApproximatelyEqual(to: exact.cornerEnd, tolerance: 0.0002))
    }

    @Test(
        "Effective cut length is continuous through 180 degrees",
        arguments: RadiusCase.all,
        [CornerStyle.RoundingStyle.circular, .continuous]
    )
    func cutLengthIsContinuousThroughStraightAngle(
        radius: RadiusCase,
        roundingStyle: CornerStyle.RoundingStyle
    ) {
        let corner = Corner(
            .rounded(radius: radius.value, style: roundingStyle),
            point: CGPoint.zero
        )
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

        let cutLengthMultiplier = roundingStyle == .continuous
            ? Corner.Dimensions.continuousCutLengthMultiplier(for: .degrees(180))
            : 1
        let expectedCutLength: CGFloat = switch radius.name {
        case "absolute": 0
        case "relative": 50 * cutLengthMultiplier
        default: 25 * cutLengthMultiplier
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
        case .automatic, .point:
            expected.move(to: .zero)
        case .rounded:
            expected.move(to: CGPoint(x: 50, y: 0))
        case .roundedContinuous:
            expected.move(to: dimensions.cornerStart)
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
        case .automatic, .point:
            expected.move(to: .zero)
        case .rounded, .concave, .straight:
            expected.move(to: CGPoint(x: -50, y: 0))
            expected.addLine(to: CGPoint(x: 50, y: 0))
        case .roundedContinuous:
            expected.move(to: dimensions.cornerStart)
            expected.addLine(to: dimensions.cornerEnd)
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

    @Test("A 90-degree continuous corner follows SwiftUI's rendered boundary")
    func rightAngleContinuousCornerFollowsSwiftUIRenderedBoundary() throws {
        let radius: CGFloat = 20
        let corner = Corner(
            .rounded(radius: .absolute(radius), style: .continuous),
            point: CGPoint(x: 100, y: 100)
        )
        let dimensions = corner.dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(x: 0, y: 100)
        )

        // Normalized boundary samples captured from a high-resolution direct
        // rendering rather than RoundedRectangle's public Path elements.
        let renderedSamples = [
            CGPoint(x: 0.05224609375, y: 0.7141307043650794),
            CGPoint(x: 0.15380859375, y: 0.4682883057323218),
            CGPoint(x: 0.25537109375, y: 0.3308582850864955),
            CGPoint(x: 0.35693359375, y: 0.23291576488597973),
            CGPoint(x: 0.45849609375, y: 0.15983157274199694),
            CGPoint(x: 0.56005859375, y: 0.10502845971017744),
            CGPoint(x: 0.66162109375, y: 0.06640625),
            CGPoint(x: 0.76318359375, y: 0.041094098772321425),
            CGPoint(x: 0.86474609375, y: 0.023780545339200824),
            CGPoint(x: 0.96630859375, y: 0.012692019584556492),
            CGPoint(x: 1.06787109375, y: 0.006321109794670927),
            CGPoint(x: 1.16943359375, y: 0.0028365867725317026)
        ]
        let profile = (0...2048).map { step in
            let point = dimensions.continuousCornerPoint(
                at: CGFloat(step) / 2048
            )
            return CGPoint(
                x: abs(point.x - corner.point.x) / radius,
                y: abs(point.y - corner.point.y) / radius
            )
        }

        for sample in renderedSamples {
            let error = try #require(profile.map {
                CubicPathTestSupport.distance(from: $0, to: sample)
            }.min())
            #expect(error <= 0.006)
        }
    }

    @Test("The continuous reference profile is symmetric")
    func continuousReferenceProfileIsSymmetric() {
        let corner = Corner(
            .rounded(radius: .absolute(20), style: .continuous),
            point: CGPoint(x: 100, y: 100)
        )
        let dimensions = corner.dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(x: 0, y: 100)
        )

        for step in 0...64 {
            let parameter = CGFloat(step) / 64
            let first = dimensions.continuousCornerPoint(at: parameter)
            let mirrored = dimensions.continuousCornerPoint(at: 1 - parameter)
            let firstOffset = CGPoint(
                x: abs(first.x - corner.point.x),
                y: abs(first.y - corner.point.y)
            )
            let mirroredOffset = CGPoint(
                x: abs(mirrored.x - corner.point.x),
                y: abs(mirrored.y - corner.point.y)
            )

            #expect(abs(firstOffset.x - mirroredOffset.y) <= 1e-9)
            #expect(abs(firstOffset.y - mirroredOffset.x) <= 1e-9)
        }
    }

    @Test(
        "Rounding styles resolve the same nominal radius",
        arguments: RadiusCase.all
    )
    func roundingStylesResolveTheSameNominalRadius(radius: RadiusCase) {
        let circular = Corner(
            .rounded(radius: radius.value),
            point: CGPoint.zero
        ).dimensions(
            previousPoint: CGPoint(x: 0, y: 100),
            nextPoint: CGPoint(x: 100, y: 0)
        )
        let continuous = Corner(
            .rounded(radius: radius.value, style: .continuous),
            point: CGPoint.zero
        ).dimensions(
            previousPoint: CGPoint(x: 0, y: 100),
            nextPoint: CGPoint(x: 100, y: 0)
        )

        #expect(continuous.absoluteRadius.isApproximatelyEqual(
            to: circular.absoluteRadius,
            tolerance: 1e-10
        ))
        let multiplier = Corner.Dimensions.continuousCutLengthMultiplier(
            for: continuous.angle
        )
        #expect(continuous.cutLength.isApproximatelyEqual(
            to: circular.cutLength * multiplier,
            tolerance: 1e-10
        ))
    }

    @Test(
        "A relative continuous radius retains its nominal scale at arbitrary angles",
        arguments: ContinuousCornerAngleCase.all
    )
    func relativeContinuousRadiusRetainsNominalScale(angle: ContinuousCornerAngleCase) {
        let radius = RelatableValue.relative(0.25)
        let circular = Corner(
            .rounded(radius: radius),
            point: CGPoint.zero
        ).dimensions(previousPoint: angle.previous, nextPoint: angle.next)
        let continuous = Corner(
            .rounded(radius: radius, style: .continuous),
            point: CGPoint.zero
        ).dimensions(previousPoint: angle.previous, nextPoint: angle.next)

        #expect(continuous.absoluteRadius.isApproximatelyEqual(
            to: circular.absoluteRadius,
            tolerance: 1e-8
        ))
        let multiplier = Corner.Dimensions.continuousCutLengthMultiplier(
            for: continuous.angle
        )
        #expect(continuous.cutLength.isApproximatelyEqual(
            to: circular.cutLength * multiplier,
            tolerance: 1e-8
        ))
    }

    @Test(
        "Continuous corners retain SwiftUI's curvature scale at arbitrary angles",
        arguments: [
            CGFloat(15), 30, 60, 68.19859051364818, 89,
            91, 111.80140948635182, 120, 150, 165
        ]
    )
    func continuousCornersRetainSwiftUICurvatureScale(degrees: CGFloat) throws {
        let radius: CGFloat = 25
        let reference = Corner(
            .rounded(radius: .absolute(radius), style: .continuous),
            point: CGPoint.zero
        ).dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(x: 0, y: 100)
        )
        let angle = Angle.degrees(degrees)
        let dimensions = Corner(
            .rounded(radius: .absolute(radius), style: .continuous),
            point: CGPoint.zero
        ).dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(
                x: 100 * cos(angle.radians),
                y: 100 * sin(angle.radians)
            )
        )

        let referenceSegments = CubicPathTestSupport.segments(
            in: path(for: reference)
        )
        let segments = CubicPathTestSupport.segments(
            in: path(for: dimensions)
        )
        let referenceMiddle = try #require(referenceSegments.dropFirst(6).first)
        let middle = try #require(segments.dropFirst(6).first)
        let referenceRatio = referenceMiddle.curvatureRadius(at: 0.5)
            / reference.absoluteRadius
        let ratio = middle.curvatureRadius(at: 0.5)
            / dimensions.absoluteRadius
        let difference: CGFloat = abs(ratio - referenceRatio)

        #expect(difference <= 0.02)
    }

    @Test(
        "Continuous-corner approximation stays within tolerance",
        arguments: [CGFloat(15), 45, 135, 165]
    )
    func continuousCornerApproximationStaysWithinTolerance(degrees: CGFloat) throws {
        let angle = Angle.degrees(degrees)
        let dimensions = Corner(
            .rounded(radius: 20, style: .continuous),
            point: CGPoint.zero
        ).dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(
                x: 100 * cos(angle.radians),
                y: 100 * sin(angle.radians)
            )
        )
        var path = Path()
        dimensions.addCornerShape(to: &path, moveToStart: true)
        let segments = CubicPathTestSupport.segments(in: path)
        try #require(segments.count == 16)
        // Keep the cubic path within 0.2% of the corner footprint, with a
        // 0.01-point floor for very small corners and Path storage precision.
        let tolerance = max(dimensions.cutLength * 2e-3, 0.01)

        let errors = (0...64).map { step in
            let parameter = CGFloat(step) / 64
            let scaledParameter = parameter * CGFloat(segments.count)
            let index = min(Int(scaledParameter), segments.count - 1)
            let localParameter = scaledParameter - CGFloat(index)
            let actual = segments[index].point(at: localParameter)
            let expected = dimensions.continuousCornerPoint(at: parameter)
            return CubicPathTestSupport.distance(
                from: actual,
                to: expected
            )
        }
        let maxError = try #require(errors.max())
        #expect(maxError <= tolerance)
    }

    @Test(
        "Continuous corners have zero-curvature edge joins at arbitrary angles",
        arguments: ContinuousCornerAngleCase.all
    )
    func continuousCornersHaveZeroCurvatureEdgeJoins(angle: ContinuousCornerAngleCase) throws {
        let corner = Corner(
            .rounded(radius: 20, style: .continuous),
            point: CGPoint.zero
        )
        let dimensions = corner.dimensions(
            previousPoint: angle.previous,
            nextPoint: angle.next
        )
        let segments = CubicPathTestSupport.segments(
            in: path(for: dimensions)
        )
        let first = try #require(segments.first)
        let last = try #require(segments.last)
        let tolerance = max(dimensions.cutLength * 1e-6, 1e-6)

        #expect(first.start.isApproximatelyEqual(
            to: dimensions.cornerStart,
            tolerance: tolerance
        ))
        #expect(last.end.isApproximatelyEqual(
            to: dimensions.cornerEnd,
            tolerance: tolerance
        ))
        #expect(CubicPathTestSupport.distance(
            from: first.control1,
            toLineFrom: first.start,
            through: corner.point
        ) <= tolerance)
        #expect(CubicPathTestSupport.distance(
            from: first.control2,
            toLineFrom: first.start,
            through: corner.point
        ) <= tolerance)
        #expect(CubicPathTestSupport.distance(
            from: last.control1,
            toLineFrom: corner.point,
            through: last.end
        ) <= tolerance)
        #expect(CubicPathTestSupport.distance(
            from: last.control2,
            toLineFrom: corner.point,
            through: last.end
        ) <= tolerance)

        for (firstSegment, secondSegment) in zip(segments, segments.dropFirst()) {
            let incoming = firstSegment.end.vector - firstSegment.control2.vector
            let outgoing = secondSegment.control1.vector - secondSegment.start.vector
            #expect(incoming.normalized.crossProduct(with: outgoing.normalized).magnitude <= 1e-4)
        }
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
        case .automatic:
            .automatic
        case .point:
            .point
        case .rounded:
            .rounded(radius: radius)
        case .roundedContinuous:
            .rounded(radius: radius, style: .continuous)
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
