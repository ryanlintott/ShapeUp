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

    /// A corner sitting on or beside one of the two angle singularities, paired
    /// with an inset, so a failure names the sample it came from.
    struct SingularityCase: CustomTestStringConvertible, Sendable {
        let name: String
        let previous: CGPoint
        let next: CGPoint
        let inset: CGFloat

        var testDescription: String { "\(name) inset \(inset)" }

        private static let positions: [(name: String, previous: CGPoint, next: CGPoint)] = [
            ("before zero", CGPoint(x: 100, y: -0.0001), CGPoint(x: 100, y: 0.0001)),
            ("zero", CGPoint(x: 100, y: 0), CGPoint(x: 100, y: 0)),
            ("after zero", CGPoint(x: 100, y: 0.0001), CGPoint(x: 100, y: -0.0001)),
            ("before straight", CGPoint(x: -100, y: -0.0001), CGPoint(x: 100, y: -0.0001)),
            ("straight", CGPoint(x: -100, y: 0), CGPoint(x: 100, y: 0)),
            ("after straight", CGPoint(x: -100, y: 0.0001), CGPoint(x: 100, y: 0.0001))
        ]

        static let all: [Self] = positions.flatMap { position in
            [CGFloat(12), -12].map {
                Self(
                    name: position.name,
                    previous: position.previous,
                    next: position.next,
                    inset: $0
                )
            }
        }
    }

    struct StraightCrossing: CustomTestStringConvertible, Sendable {
        let name: String
        let inset: CGFloat

        var testDescription: String { name }

        /// Straddling 180 degrees. The middle angle is the exact singularity and
        /// the outer two are the values the other two are compared against.
        static let angles: [CGFloat] = [179.9999, 180, 180.0001]

        static let all: [Self] = [
            .init(name: "straight inset", inset: 12),
            .init(name: "straight outset", inset: -12)
        ]
    }

    /// A corner angle paired with an inset amount.
    struct InsetAngleCase: CustomTestStringConvertible, Sendable {
        let degrees: CGFloat
        let inset: CGFloat

        var testDescription: String { "\(degrees) degrees inset \(inset)" }

        private static func cases(
            degrees: [CGFloat],
            insets: [CGFloat]
        ) -> [Self] {
            degrees.flatMap { degrees in
                insets.map { Self(degrees: degrees, inset: $0) }
            }
        }

        /// Angles spread across the usable range, inset both ways.
        static let all: [Self] = cases(
            degrees: [15, 30, 60, 120, 150],
            insets: [5, -5]
        )

        /// Sharp corners, where an inset moves the corner point farthest and a
        /// small inset is most likely to expose a scaling error.
        static let lowAngles: [Self] = cases(
            degrees: [1, 5, 10, 15, 20, 25],
            insets: [0.1, 5, -5]
        )
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
        SingularityCase.all
    )
    func insetsStayFinite(styleKind: StyleKind, sample: SingularityCase) {
        let corner = Corner(
            styleKind.style(radius: .mixed(absolute: 10, relative: 0.25)),
            point: CGPoint.zero
        )
        let insetCorner = corner
            .dimensions(previousPoint: sample.previous, nextPoint: sample.next)
            .corner(inset: sample.inset)
        let insetDimensions = insetCorner.dimensions(
            previousPoint: sample.previous,
            nextPoint: sample.next
        )
        let path = path(for: insetDimensions)

        #expect(insetCorner.point.isFinite)
        #expect(insetCorner.style.finiteScalars.allSatisfy { $0.isFinite })
        #expect(insetDimensions.finiteInsetScalars.allSatisfy { $0.isFinite })
        #expect(path.points.allSatisfy { $0.isFinite })
        #expect(path.hasFiniteBounds)
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
        let bounds = StraightCrossing.angles.map { angle in
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
        arguments: InsetAngleCase.lowAngles
    )
    func lowAngleInsetRoundingStylesRetainNominalRadius(
        sample: InsetAngleCase
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

    /// Insetting only has to produce another continuous corner with the
    /// expected nominal radius. Everything that curve then guarantees is
    /// covered by the continuous corner tests in `CornerDimensionsPathTests`.
    @Test(
        "Insetting a continuous corner keeps its style and nominal radius",
        arguments: InsetAngleCase.all
    )
    func insettingContinuousCornersKeepsStyleAndNominalRadius(
        sample: InsetAngleCase
    ) {
        let angle = Angle.degrees(sample.degrees)
        let points = [
            CGPoint(x: 100, y: 0),
            CGPoint.zero,
            CGPoint(x: 100 * cos(angle.radians), y: 100 * sin(angle.radians))
        ]
        let dimensions = Corner(
            .rounded(radius: 20, style: .continuous),
            point: points[1]
        ).dimensions(previousPoint: points[0], nextPoint: points[2])
        let insetCorner = dimensions.corner(inset: sample.inset)

        #expect(insetCorner.point.isApproximatelyEqual(
            to: points.insetPoints(sample.inset)[1],
            tolerance: 1e-10
        ))
        #expect(insetCorner.style == .rounded(
            radius: .absolute(
                dimensions.absoluteRadius - (sample.inset * dimensions.reflexMultiplier)
            ),
            style: .continuous
        ))
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
