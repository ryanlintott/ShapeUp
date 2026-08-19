//
//  RelativeCornerTests.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-13.
//

@testable import ShapeUp
import SwiftUI
import Testing

struct RelativeCornerTests {
    @Test("Mixed movement separates relative and absolute amounts")
    func mixedMovementSeparatesRelativeAndAbsoluteAmounts() {
        let original = RelativeCorner(.rounded(radius: 5), x: 0.25, y: 0.75)
            .moved(dx: .absolute(2), dy: .absolute(3))

        let moved = original.moved(
            dx: .mixed(absolute: 10, relative: 0.5),
            dy: .mixed(absolute: -6, relative: -0.25)
        )

        #expect(moved.anchor == .relative(x: 0.75, y: 0.5))
        #expect(moved.offset == Vector2(dx: 12, dy: -3))
        #expect(moved.style == original.style)
    }

    @Test("Rectangle conversion applies offsets when both axes are collapsed")
    func rectangleConversionAppliesOffsetsWhenBothAxesAreCollapsed() {
        let rect = CGRect(x: 10, y: 20, width: 0, height: 0)
        let relativeCorner = RelativeCorner.center.moved(dx: 7, dy: -9)

        let corner = relativeCorner.corner(in: rect)

        #expect(corner.point == CGPoint(x: 17, y: 11))
    }

    @Test("Frame conversion projects offsets along normalized axes")
    func frameConversionProjectsOffsetsAlongNormalizedAxes() {
        let frame = CGFrame(
            origin: CGPoint(x: 10, y: 20),
            xAxis: Vector2(dx: 0, dy: 100),
            yAxis: Vector2(dx: -50, dy: 0)
        )
        let relativeCorner = RelativeCorner(x: 0.25, y: 0.5)
            .moved(dx: 8, dy: -4)

        let corner = relativeCorner.corner(in: frame)

        #expect(corner.point == CGPoint(x: -11, y: 53))
    }

    @Test("Frame conversion projects offsets along axes that are not perpendicular")
    func frameConversionProjectsOffsetsAlongAxesThatAreNotPerpendicular() {
        let frame = CGFrame(
            origin: CGPoint(x: 10, y: 20),
            xAxis: Vector2(dx: 30, dy: 40),
            yAxis: Vector2(dx: -12, dy: 5)
        )
        let relativeCorner = RelativeCorner.topLeft.moved(dx: 10, dy: 13)

        let corner = relativeCorner.corner(in: frame)

        #expect(abs(corner.x - 4) < 1e-12)
        #expect(abs(corner.y - 33) < 1e-12)
    }

    @Test("Frame conversion omits offsets along collapsed axes")
    func frameConversionOmitsOffsetsAlongCollapsedAxes() {
        let frame = CGFrame(
            origin: CGPoint(x: 10, y: 20),
            xAxis: .zero,
            yAxis: Vector2(dx: 0, dy: 100)
        )
        let relativeCorner = RelativeCorner.center.moved(dx: 7, dy: -9)

        let corner = relativeCorner.corner(in: frame)

        #expect(corner.point == CGPoint(x: 10, y: 61))
    }
}
