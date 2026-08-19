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

        var previous: CGPoint { previous(arm: 100) }

        var next: CGPoint { next(arm: 100) }

        func previous(arm: CGFloat) -> CGPoint { CGPoint(x: arm, y: 0) }

        /// The corner is scale-free, so lengthening the arms scales the whole
        /// configuration and lets a large radius be measured without being
        /// fitted down to the shorter adjacent segment.
        func next(arm: CGFloat) -> CGPoint {
            let angle = Angle.degrees(degrees * (reflex ? -1 : 1))
            return CGPoint(
                x: arm * cos(angle.radians),
                y: arm * sin(angle.radians)
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

        // Boundary samples of the shape SwiftUI actually draws, measured from
        // rendered pixels alone by `ContinuousCornerRasterProbe`, which is
        // accurate to about 0.0004 radii. Deliberately not taken from
        // `RoundedRectangle(style: .continuous).path(in:)`, whose elements sit
        // roughly 0.0015 radii from what gets rasterised.
        //
        // Only half the curve is listed. It is symmetric about its diagonal, so
        // each sample is checked against the profile and its mirror.
        let renderedSamples = [
            CGPoint(x: 0.011144642, y: 0.988619792),
            CGPoint(x: 0.017009861, y: 0.915095486),
            CGPoint(x: 0.022875080, y: 0.862178819),
            CGPoint(x: 0.031672909, y: 0.803446181),
            CGPoint(x: 0.046335957, y: 0.730928819),
            CGPoint(x: 0.063931614, y: 0.665946181),
            CGPoint(x: 0.084459881, y: 0.605928819),
            CGPoint(x: 0.107920757, y: 0.550703125),
            CGPoint(x: 0.140179462, y: 0.488203125),
            CGPoint(x: 0.172438166, y: 0.436362847),
            CGPoint(x: 0.210562090, y: 0.384053819),
            CGPoint(x: 0.254551233, y: 0.332213542),
            CGPoint(x: 0.298540376, y: 0.286454861)
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
            let mirrored = CGPoint(x: sample.y, y: sample.x)
            let error = try #require(profile.map {
                min(
                    CubicPathTestSupport.distance(from: $0, to: sample),
                    CubicPathTestSupport.distance(from: $0, to: mirrored)
                )
            }.min())
            // The measurement is good to about 0.0004, and the profile is
            // fitted to it, so this is far tighter than the 0.006 it replaced.
            #expect(error <= 0.0015)
        }
    }

    @Test("A 90-degree continuous corner uses SwiftUI's measured edge length")
    func rightAngleContinuousCornerUsesSwiftUIEdgeLength() {
        let radius: CGFloat = 20
        let dimensions = Corner(
            .rounded(radius: .absolute(radius), style: .continuous),
            point: CGPoint.zero
        ).dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(x: 0, y: 100)
        )

        // SwiftUI's continuous 90-degree corner reaches this many times as far
        // along each edge as a circular corner of the same radius. The whole
        // profile is calibrated to this one measurement.
        #expect(dimensions.cutLength.isApproximatelyEqual(
            to: radius * 1.5286649465560913,
            tolerance: 1e-9
        ))
    }

    /// The same 90-degree corner, compared against SwiftUI's *path elements*
    /// rather than against what it draws.
    ///
    /// Those elements are a real path, and identical to what the private
    /// `CGPathCreateWithContinuousRoundedRect` returns, but they are not the
    /// shape SwiftUI rasterises. This is here so the size of that difference
    /// stays visible: the corner tracks the rendered shape far more closely
    /// than it tracks the path elements, and that is deliberate.
    @Test("The corner sits further from SwiftUI's path elements than from its rendering")
    func comparedWithPathElements() throws {
        let radius: CGFloat = 20
        let dimensions = Corner(
            .rounded(radius: .absolute(radius), style: .continuous),
            point: CGPoint(x: 100, y: 100)
        ).dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(x: 0, y: 100)
        )
        let profile = (0...2048).map { step -> CGPoint in
            let point = dimensions.continuousCornerPoint(at: CGFloat(step) / 2048)
            return CGPoint(
                x: abs(point.x - 100) / radius,
                y: abs(point.y - 100) / radius
            )
        }

        // One corner of SwiftUI's path, in the same frame.
        let source = RoundedRectangle(cornerRadius: 100, style: .continuous)
            .path(in: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        var elements: [CGPoint] = []
        var current = CGPoint.zero
        source.forEach { element in
            switch element {
            case let .move(to: point): current = point
            case let .line(to: point): current = point
            case let .curve(to: point, control1: c1, control2: c2):
                if max(current.x, point.x) < 300, max(current.y, point.y) < 300 {
                    for step in 0...400 {
                        let t = CGFloat(step) / 400, m = 1 - t
                        elements.append(CGPoint(
                            x: (m * m * m * current.x + 3 * m * m * t * c1.x
                                + 3 * m * t * t * c2.x + t * t * t * point.x) / 100,
                            y: (m * m * m * current.y + 3 * m * m * t * c1.y
                                + 3 * m * t * t * c2.y + t * t * t * point.y) / 100
                        ))
                    }
                }
                current = point
            case let .quadCurve(to: point, control: _): current = point
            case .closeSubpath: break
            }
        }
        try #require(!elements.isEmpty)

        let fromElements = try #require(elements.map { element in
            profile.map { CubicPathTestSupport.distance(from: $0, to: element) }.min() ?? .infinity
        }.max())

        // Around 0.0015, the same gap the raster probe measures between the
        // path elements and the rendered shape. Well above the 0.0004 the
        // corner sits from the rendering itself.
        #expect(fromElements > 0.0005)
        #expect(fromElements < 0.004)
    }

    @Test("The continuous profile turns symmetrically about its midpoint")
    func continuousProfileIsSymmetric() {
        for step in 0...32 {
            let parameter = CGFloat(step) / 32
            let turn = ContinuousCornerProfile.turnFraction(at: parameter)
            let mirroredTurn = ContinuousCornerProfile.turnFraction(at: 1 - parameter)

            #expect(abs(turn + mirroredTurn - 1) <= 1e-12)
        }
    }

    @Test(
        "Rounding styles resolve the same nominal radius at every angle",
        arguments: RadiusCase.all,
        ContinuousCornerAngleCase.all
    )
    func roundingStylesResolveTheSameNominalRadius(
        radius: RadiusCase,
        angle: ContinuousCornerAngleCase
    ) {
        let circular = Corner(
            .rounded(radius: radius.value),
            point: CGPoint.zero
        ).dimensions(previousPoint: angle.previous, nextPoint: angle.next)
        let continuous = Corner(
            .rounded(radius: radius.value, style: .continuous),
            point: CGPoint.zero
        ).dimensions(previousPoint: angle.previous, nextPoint: angle.next)

        if continuous.cutLength < continuous.maxCutLength,
           circular.cutLength < circular.maxCutLength {
            #expect(continuous.absoluteRadius.isApproximatelyEqual(
                to: circular.absoluteRadius,
                tolerance: 1e-8
            ))
        } else {
            // A radius too large for its corner is fitted to the shorter
            // adjacent segment. A continuous corner spends more of that segment
            // on the same radius, so it reaches the limit first.
            #expect(continuous.absoluteRadius <= circular.absoluteRadius)
        }
    }

    @Test(
        "Continuous corners hold their curvature scale at every angle",
        arguments: ContinuousCornerAngleCase.all
    )
    func continuousCornersHoldCurvatureScale(angle: ContinuousCornerAngleCase) throws {
        let dimensions = Corner(
            .rounded(radius: .absolute(25), style: .continuous),
            point: CGPoint.zero
        ).dimensions(previousPoint: angle.previous, nextPoint: angle.next)

        // The tightest curvature of a circular corner is its radius. A
        // continuous corner instead reaches a fixed fraction of it, and that
        // fraction is what has to stay put as the angle changes.
        let tightestCurvatureRadius = CubicPathTestSupport
            .segments(in: path(for: dimensions))
            .flatMap { segment in
                (0...8).map { segment.curvatureRadius(at: CGFloat($0) / 8) }
            }
            .min()
        let ratio = try #require(tightestCurvatureRadius) / dimensions.absoluteRadius

        #expect(abs(ratio - 0.83) <= 0.02)
    }

    @Test(
        "The cubic path stays on the continuous corner curve",
        arguments: ContinuousCornerAngleCase.all,
        [CGFloat(20), 500]
    )
    func continuousCornerPathStaysOnItsCurve(
        angle: ContinuousCornerAngleCase,
        radius: CGFloat
    ) throws {
        // Arms long enough that even the sharpest corner keeps its full
        // radius. Two radii an order of magnitude apart check that nothing in
        // the corner depends on absolute scale.
        let arm = radius * 200
        let dimensions = Corner(
            .rounded(radius: .absolute(radius), style: .continuous),
            point: CGPoint.zero
        ).dimensions(
            previousPoint: angle.previous(arm: arm),
            nextPoint: angle.next(arm: arm)
        )
        let curve = (0...1024).map {
            dimensions.continuousCornerPoint(at: CGFloat($0) / 1024)
        }

        // The deviation of a cubic path from its curve is a fixed fraction of
        // the radius, not a fixed distance, so the limit has to be a fraction
        // too. Sixteen segments hold about 3e-5 of the radius; this leaves room
        // for arithmetic differences while still failing if the curve is
        // tessellated more coarsely.
        let tolerance = dimensions.absoluteRadius * 1e-4

        let deviation = CubicPathTestSupport
            .segments(in: path(for: dimensions))
            .flatMap { segment in
                (0...16).map { segment.point(at: CGFloat($0) / 16) }
            }
            .map { CubicPathTestSupport.distance(from: $0, toPolyline: curve) }
            .max()

        #expect(dimensions.absoluteRadius.isApproximatelyEqual(to: radius, tolerance: 1e-9))
        #expect(try #require(deviation) <= tolerance)
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
            halvedTurnAngle.radians,
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
