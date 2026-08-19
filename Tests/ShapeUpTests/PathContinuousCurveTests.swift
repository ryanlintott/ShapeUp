//
//  PathContinuousCurveTests.swift
//  ShapeUpTests
//
//  Created by Ryan Lintott on 2026-08-17.
//

@testable import ShapeUp
import SwiftUI
import Testing

struct PathContinuousCurveTests {
    @Test(
        "A standalone continuous curve matches a continuous corner's geometry",
        arguments: [CGFloat(15), 45, 90, 135, 165],
        [false, true]
    )
    func standaloneCurveMatchesCornerGeometry(degrees: CGFloat, reflex: Bool) throws {
        let radius: CGFloat = 20
        // Long enough that even the sharpest tested angle keeps its full
        // requested radius, rather than being fitted to a shorter segment.
        let arm: CGFloat = 2000
        let previous = CGPoint(x: arm, y: 0)
        let vertex = CGPoint.zero
        let angle = Angle.degrees(degrees * (reflex ? -1 : 1))
        let next = CGPoint(x: arm * cos(angle.radians), y: arm * sin(angle.radians))

        var direct = Path()
        direct.move(to: previous)
        direct.addContinuousCurve(tangent1End: vertex, tangent2End: next, radius: radius)

        let dimensions = Corner(
            .rounded(radius: .absolute(radius), style: .continuous),
            point: vertex
        ).dimensions(previousPoint: previous, nextPoint: next)
        var viaCorner = Path()
        dimensions.addCornerShape(to: &viaCorner, moveToStart: true)

        let directSegments = CubicPathTestSupport.segments(in: direct)
        let cornerSegments = CubicPathTestSupport.segments(in: viaCorner)
        #expect(directSegments.count == cornerSegments.count)

        for (a, b) in zip(directSegments, cornerSegments) {
            #expect(CubicPathTestSupport.distance(from: a.start, to: b.start) <= 1e-6)
            #expect(CubicPathTestSupport.distance(from: a.end, to: b.end) <= 1e-6)
            #expect(CubicPathTestSupport.distance(from: a.control1, to: b.control1) <= 1e-6)
            #expect(CubicPathTestSupport.distance(from: a.control2, to: b.control2) <= 1e-6)
        }
    }

    @Test("A connecting line is added when the current point isn't at the curve's start")
    func connectingLineAddedWhenNeeded() throws {
        var path = Path()
        path.move(to: CGPoint(x: 50, y: 0))
        path.addContinuousCurve(
            tangent1End: CGPoint.zero,
            tangent2End: CGPoint(x: 0, y: 100),
            radius: 20
        )

        var sawLine = false
        path.forEach { element in
            if case .line = element { sawLine = true }
        }
        #expect(sawLine)
        #expect(CubicPathTestSupport.segments(in: path).count == 16)
    }

    @Test("No connecting line is added when the current point is already at the curve's start")
    func noConnectingLineWhenAlreadyPositioned() throws {
        let dimensions = Corner(
            .rounded(radius: .absolute(20), style: .continuous),
            point: CGPoint.zero
        ).dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(x: 0, y: 100)
        )

        var path = Path()
        path.move(to: dimensions.cornerStart)
        path.addContinuousCurve(
            tangent1End: CGPoint.zero,
            tangent2End: dimensions.cornerEnd,
            radius: dimensions.absoluteRadius
        )

        var lineCount = 0
        path.forEach { element in
            if case .line = element { lineCount += 1 }
        }
        #expect(lineCount == 0)
    }

    /// A corner folded back on itself has tangent points infinitely far away,
    /// and a straight one has a curve of no length. Neither describes a curve at
    /// any finite radius, so both collapse to a line, the same way `addArc`
    /// does with collinear points.
    @Test(
        "Collinear points add a line instead of a curve",
        arguments: [
            // Zero degrees: the previous and next points share a direction.
            CGPoint(x: 100, y: 0),
            // 180 degrees: the corner does not turn at all.
            CGPoint(x: -100, y: 0)
        ]
    )
    func collinearPointsAddALine(tangent2End: CGPoint) {
        let start = CGPoint(x: 100, y: 0)
        let vertex = CGPoint.zero

        var path = Path()
        path.move(to: start)
        path.addContinuousCurve(
            tangent1End: vertex,
            tangent2End: tangent2End,
            radius: 20
        )

        #expect(CubicPathTestSupport.segments(in: path).isEmpty)
        #expect(path.currentPoint == vertex)
        #expect(path.boundingRect.isApproximatelyEqual(
            to: CGRect(x: 0, y: 0, width: 100, height: 0),
            tolerance: 1e-9
        ))
    }

    @Test(
        "A non-positive radius adds a line instead of a curve",
        arguments: [CGFloat(0), -20]
    )
    func nonPositiveRadiusAddsALine(radius: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: 100, y: 0))
        path.addContinuousCurve(
            tangent1End: CGPoint.zero,
            tangent2End: CGPoint(x: 0, y: 100),
            radius: radius
        )

        #expect(CubicPathTestSupport.segments(in: path).isEmpty)
        #expect(path.currentPoint == CGPoint.zero)
    }

    @Test("A zero length tangent line adds nothing")
    func zeroLengthTangentLineAddsNothing() {
        let vertex = CGPoint.zero

        var path = Path()
        path.move(to: vertex)
        path.addContinuousCurve(
            tangent1End: vertex,
            tangent2End: CGPoint(x: 0, y: 100),
            radius: 20
        )

        #expect(CubicPathTestSupport.segments(in: path).isEmpty)
        #expect(path.currentPoint == vertex)
    }

    @Test("Adding a continuous curve with no current point moves to the first tangent point")
    func noCurrentPointMovesToTangent1End() {
        var path = Path()
        path.addContinuousCurve(
            tangent1End: CGPoint(x: 10, y: 20),
            tangent2End: CGPoint(x: 30, y: 20),
            radius: 5
        )

        #expect(path.currentPoint == CGPoint(x: 10, y: 20))
        #expect(CubicPathTestSupport.segments(in: path).isEmpty)
    }
}
