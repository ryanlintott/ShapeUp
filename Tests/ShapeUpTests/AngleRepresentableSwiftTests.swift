//
//  AngleRepresentableSwiftTests.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-07-15.
//

@testable import ShapeUp
import SwiftUI
import Testing

struct AngleRepresentableSwiftTests {
    private struct TestAngle: AngleRepresentable {
        let radians: Double
    }

    struct Sample: CustomTestStringConvertible, Sendable {
        let name: String
        let degrees: Double
        let isApproximatelyZero: Bool
        let isApproximatelyStraight: Bool

        var testDescription: String { name }

        static let all: [Self] = [
            .init(name: "zero", degrees: 0, isApproximatelyZero: true, isApproximatelyStraight: false),
            .init(name: "near zero", degrees: 1e-14, isApproximatelyZero: true, isApproximatelyStraight: false),
            .init(name: "near negative zero", degrees: -1e-14, isApproximatelyZero: true, isApproximatelyStraight: false),
            .init(name: "full rotation", degrees: 360, isApproximatelyZero: true, isApproximatelyStraight: false),
            .init(name: "right angle", degrees: 90, isApproximatelyZero: false, isApproximatelyStraight: false),
            .init(name: "near straight", degrees: 180 - 1e-14, isApproximatelyZero: false, isApproximatelyStraight: true),
            .init(name: "negative straight", degrees: -180, isApproximatelyZero: false, isApproximatelyStraight: true),
            .init(name: "reflex straight", degrees: 540, isApproximatelyZero: false, isApproximatelyStraight: true),
            .init(name: "not quite straight", degrees: 179.999, isApproximatelyZero: false, isApproximatelyStraight: false)
        ]
    }

    @Test("Half-angle sine is available to AngleRepresentable values and Angle")
    func halfAngleSine() {
        let radians = Double.pi / 3
        let expected = 0.5

        #expect(abs(TestAngle(radians: radians).halfAngleSine - expected) < 1e-12)
        #expect(abs(Angle.radians(radians).halfAngleSine - expected) < 1e-12)
        #expect(abs(TestAngle(radians: -radians).halfAngleSine + expected) < 1e-12)
        #expect(abs(Angle.radians(-radians).halfAngleSine + expected) < 1e-12)
    }

    @Test(
        "Approximation checks support AngleRepresentable values and Angle",
        arguments: Sample.all
    )
    func approximationChecks(sample: Sample) {
        let angle = Angle.degrees(sample.degrees)
        let testAngle = TestAngle(radians: angle.radians)

        #expect(testAngle.isApproximatelyZero() == sample.isApproximatelyZero)
        #expect(angle.isApproximatelyZero() == sample.isApproximatelyZero)
        #expect(testAngle.isApproximatelyStraight() == sample.isApproximatelyStraight)
        #expect(angle.isApproximatelyStraight() == sample.isApproximatelyStraight)
    }

    @Test("Approximation checks accept a custom degree tolerance")
    func customTolerance() {
        let nearZero = Angle.degrees(0.005)
        let nearStraight = Angle.degrees(179.995)

        #expect(nearZero.isApproximatelyZero() == false)
        #expect(nearZero.isApproximatelyZero(tolerance: 0.01))
        #expect(nearStraight.isApproximatelyStraight() == false)
        #expect(nearStraight.isApproximatelyStraight(tolerance: 0.01))
    }
}
