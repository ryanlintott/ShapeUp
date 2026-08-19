//
//  CGPointRelativeTests.swift
//
//
//  Created by Ryan Lintott on 2026-06-13.
//

@testable import ShapeUp
import SwiftUI
import XCTest

final class CGPointRelativeTests: XCTestCase {
    func testRelativePositionPreservesYAxisWhenXAxisIsZero() {
        let source = CGRect(x: 10, y: 20, width: 0, height: 100)
        let point = CGPoint(x: 10, y: 70)

        let relativePoint = point.relative(to: source).relativePoint

        XCTAssertEqual(relativePoint.x, 0, accuracy: 1e-12)
        XCTAssertEqual(relativePoint.y, 0.5, accuracy: 1e-12)
    }

    func testRelativePositionPreservesXAxisWhenYAxisIsZero() {
        let source = CGRect(x: 10, y: 20, width: 100, height: 0)
        let point = CGPoint(x: 60, y: 20)

        let relativePoint = point.relative(to: source).relativePoint

        XCTAssertEqual(relativePoint.x, 0.5, accuracy: 1e-12)
        XCTAssertEqual(relativePoint.y, 0, accuracy: 1e-12)
    }

    func testRelativePositionPreservesRotatedNonzeroAxis() {
        let source = CGFrame(
            origin: CGPoint(x: 10, y: 20),
            size: CGSize(width: 0, height: 100),
            rotation: .degrees(30)
        )
        let point = source[0, 0.5]

        let relativePoint = point.relative(to: source).relativePoint

        XCTAssertEqual(relativePoint.x, 0, accuracy: 1e-12)
        XCTAssertEqual(relativePoint.y, 0.5, accuracy: 1e-12)
    }

    func testRelativePositionSupportsSmallFrames() {
        let source = CGRect(x: 10, y: 20, width: 1e-6, height: 1e-6)
        let point = source[0.25, 0.75]

        let relativePoint = point.relative(to: source).relativePoint

        XCTAssertEqual(relativePoint.x, 0.25, accuracy: 1e-8)
        XCTAssertEqual(relativePoint.y, 0.75, accuracy: 1e-8)
    }

    func testRelativePositionInFullyCollapsedFrameIsTopLeft() {
        let source = CGRect(x: 10, y: 20, width: 0, height: 0)
        let point = CGPoint(x: 30, y: 40)

        XCTAssertEqual(point.relative(to: source), .topLeft)
    }
}
