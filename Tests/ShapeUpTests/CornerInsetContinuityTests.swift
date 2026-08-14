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

    struct ContinuousCornerInsetCase: CustomTestStringConvertible, Sendable {
        let degrees: CGFloat
        let inset: CGFloat

        var testDescription: String { "\(degrees) degrees inset \(inset)" }

        static let all: [Self] = [CGFloat(15), 30, 60, 120, 150].flatMap { degrees in
            [
                .init(degrees: degrees, inset: 5),
                .init(degrees: degrees, inset: -5)
            ]
        }
    }

    struct LowAngleInsetCase: CustomTestStringConvertible, Sendable {
        let degrees: CGFloat
        let inset: CGFloat

        var testDescription: String { "\(degrees) degrees inset \(inset)" }

        static let all: [Self] = [CGFloat(1), 5, 10, 15, 20, 25]
            .flatMap { degrees in
                [
                    .init(degrees: degrees, inset: 0.1),
                    .init(degrees: degrees, inset: 5),
                    .init(degrees: degrees, inset: -5)
                ]
            }
    }

    struct SwiftUIContinuousRectangleCase: CustomTestStringConvertible, Sendable {
        let name: String
        let size: CGSize
        let radius: CGFloat
        let inset: CGFloat

        var testDescription: String { name }

        static let all: [Self] = [
            .init(
                name: "square",
                size: CGSize(width: 100, height: 100),
                radius: 20,
                inset: 0
            ),
            .init(
                name: "inset square",
                size: CGSize(width: 100, height: 100),
                radius: 20,
                inset: 5
            ),
            .init(
                name: "example rectangle",
                size: CGSize(width: 358, height: 358 / 1.5),
                radius: 50,
                inset: 10
            ),
            .init(
                name: "outset rectangle",
                size: CGSize(width: 358, height: 358 / 1.5),
                radius: 50,
                inset: -20
            ),
            .init(
                name: "large unconstrained radius",
                size: CGSize(width: 358, height: 358 / 1.5),
                radius: 80,
                inset: 10
            ),
            .init(
                name: "large unconstrained square",
                size: CGSize(width: 329, height: 329),
                radius: 91,
                inset: 2
            )
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
        let continuous = Corner(
            .rounded(radius: 20, style: .continuous),
            point: CGPoint.zero
        )
        .dimensions(previousPoint: previous, nextPoint: next)
        .corner(inset: inset)

        #expect(rounded.point.isApproximatelyEqual(to: CGPoint(x: 10, y: 10), tolerance: 1e-10))
        #expect(rounded.style == .rounded(radius: 10))
        #expect(concave.point.isApproximatelyEqual(to: CGPoint(x: 10, y: 10), tolerance: 1e-10))
        #expect(concave.style == .concave(radius: 20, concaveInset: 10))
        #expect(continuous.point.isApproximatelyEqual(to: CGPoint(x: 10, y: 10), tolerance: 1e-10))
        #expect(continuous.style == .rounded(radius: 10, style: .continuous))
    }

    @Test(
        "Inset relative rounded radii retain the same nominal scale",
        arguments: [CGFloat(5), -5]
    )
    func insetRelativeRoundedRadiiRetainNominalScale(inset: CGFloat) {
        let previous = CGPoint(x: 0, y: 100)
        let next = CGPoint(x: 100, y: 0)
        let radius = RelatableValue.relative(0.25)
        let circularDimensions = Corner(
            .rounded(radius: radius),
            point: CGPoint.zero
        ).dimensions(previousPoint: previous, nextPoint: next)
        let continuousDimensions = Corner(
            .rounded(radius: radius, style: .continuous),
            point: CGPoint.zero
        ).dimensions(previousPoint: previous, nextPoint: next)
        let circular = circularDimensions.corner(inset: inset)
        let continuous = continuousDimensions.corner(inset: inset)
        let expectedRadius = circularDimensions.absoluteRadius - inset

        #expect(circular.style == .rounded(radius: .absolute(expectedRadius)))
        #expect(continuous.style == .rounded(
            radius: .absolute(expectedRadius),
            style: .continuous
        ))
    }

    @Test(
        "Low-angle inset rounding styles retain the same nominal radius",
        arguments: LowAngleInsetCase.all
    )
    func lowAngleInsetRoundingStylesRetainNominalRadius(
        sample: LowAngleInsetCase
    ) {
        let halfAngle = Angle.degrees(sample.degrees / 2)
        let points = [
            CGPoint.zero.moved(Vector2(magnitude: 100, direction: halfAngle)),
            CGPoint.zero,
            CGPoint.zero.moved(Vector2(magnitude: 100, direction: -halfAngle))
        ]
        let circularDimensions = Corner(
            .rounded(radius: .relative(0.25)),
            point: points[1]
        ).dimensions(previousPoint: points[0], nextPoint: points[2])
        let continuousDimensions = Corner(
            .rounded(radius: .relative(0.25), style: .continuous),
            point: points[1]
        ).dimensions(previousPoint: points[0], nextPoint: points[2])
        let insetPoints = points.insetPoints(sample.inset)
        let circularInset = circularDimensions
            .corner(inset: sample.inset)
            .dimensions(previousPoint: insetPoints[0], nextPoint: insetPoints[2])
        let continuousInset = continuousDimensions
            .corner(inset: sample.inset)
            .dimensions(previousPoint: insetPoints[0], nextPoint: insetPoints[2])

        #expect(
            abs(continuousInset.absoluteRadius - circularInset.absoluteRadius)
                <= 1e-8
        )
        #expect(continuousInset.cutLength <= continuousInset.maxCutLength)
    }

    #if os(macOS)
    @Test(
        "Unconstrained continuous rectangles approximate SwiftUI's rendering",
        arguments: SwiftUIContinuousRectangleCase.all
    )
    @available(macOS 13, *)
    @MainActor
    func continuousRectangleApproximatesSwiftUIRendering(
        sample: SwiftUIContinuousRectangleCase
    ) throws {
        let scale: CGFloat = 4
        let directMask = try RenderedShapeTestSupport.mask(scale: scale) {
            RoundedRectangle(
                cornerRadius: sample.radius,
                style: SwiftUI.RoundedCornerStyle.continuous
            )
            .inset(by: sample.inset)
            .fill(.white)
            .frame(width: sample.size.width, height: sample.size.height)
            .background(.black)
        }
        let shapeUpMask = try RenderedShapeTestSupport.mask(scale: scale) {
            CornerRectangle()
                .defaultCornerStyle(
                    .rounded(
                        radius: .absolute(sample.radius),
                        style: .continuous
                    )
                )
                .inset(by: sample.inset)
                .fill(.white)
                .frame(width: sample.size.width, height: sample.size.height)
                .background(.black)
        }
        let difference = RenderedShapeTestSupport.difference(
            between: directMask,
            and: shapeUpMask
        )
        let materialPixelLimit = Int(Double(directMask.count) * 0.006)

        #expect(
            difference.materiallyChangedPixels <= materialPixelLimit,
            "Changed: \(difference.changedPixels), material: \(difference.materiallyChangedPixels), max: \(difference.maximumDifference)"
        )
        #expect(difference.maximumDifference <= 160)
    }
    #endif

    @Test(
        "Inset continuous corners retain zero-curvature joins at arbitrary angles",
        arguments: ContinuousCornerInsetCase.all
    )
    func insetContinuousCornersRetainZeroCurvatureJoins(sample: ContinuousCornerInsetCase) throws {
        let angle = Angle.degrees(sample.degrees)
        let points = [
            CGPoint(x: 100, y: 0),
            CGPoint.zero,
            CGPoint(x: 100 * cos(angle.radians), y: 100 * sin(angle.radians))
        ]
        let corner = Corner(
            .rounded(radius: 20, style: .continuous),
            point: points[1]
        )
        let dimensions = corner.dimensions(
            previousPoint: points[0],
            nextPoint: points[2]
        )
        let insetPoints = points.insetPoints(sample.inset)
        let insetCorner = dimensions.corner(inset: sample.inset)
        let insetDimensions = insetCorner.dimensions(
            previousPoint: insetPoints[0],
            nextPoint: insetPoints[2]
        )
        let segments = CubicPathTestSupport.segments(
            in: path(for: insetDimensions)
        )
        let first = try #require(segments.first)
        let last = try #require(segments.last)
        let tolerance = max(insetDimensions.cutLength * 1e-6, 1e-6)

        #expect(insetCorner.point.isApproximatelyEqual(to: insetPoints[1], tolerance: 1e-10))
        #expect(insetCorner.style == .rounded(
            radius: .absolute(
                dimensions.absoluteRadius - (sample.inset * dimensions.reflexMultiplier)
            ),
            style: .continuous
        ))
        #expect(CubicPathTestSupport.distance(
            from: first.control1,
            toLineFrom: first.start,
            through: insetCorner.point
        ) <= tolerance)
        #expect(CubicPathTestSupport.distance(
            from: first.control2,
            toLineFrom: first.start,
            through: insetCorner.point
        ) <= tolerance)
        #expect(CubicPathTestSupport.distance(
            from: last.control1,
            toLineFrom: insetCorner.point,
            through: last.end
        ) <= tolerance)
        #expect(CubicPathTestSupport.distance(
            from: last.control2,
            toLineFrom: insetCorner.point,
            through: last.end
        ) <= tolerance)
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
        case let .rounded(radius, _), let .straight(radius, _), let .cutout(radius, _):
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
