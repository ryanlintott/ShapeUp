//
//  RelatableValueArithmeticTests.swift
//  ShapeUpTests
//
//  Created by Ryan Lintott on 2026-08-18.
//

@testable import ShapeUp
import SwiftUI
import Testing

/// Covers ``RelatableValue``'s equality, arithmetic, and animation conformances.
///
/// Adding values of different cases produces a `.mixed` result, so equality has
/// to compare components rather than cases for the `AdditiveArithmetic` and
/// `VectorArithmetic` laws to hold at all.
struct RelatableValueArithmeticTests {
    /// One value written every way that describes the same quantity.
    static let equivalentForms: [[RelatableValue]] = [
        [.absolute(0), .relative(0), .mixed(absolute: 0, relative: 0), .zero],
        [.absolute(5), .mixed(absolute: 5, relative: 0)],
        [.relative(0.25), .mixed(absolute: 0, relative: 0.25)]
    ]

    static let samples: [RelatableValue] = [
        .zero,
        .absolute(10),
        .absolute(-3),
        .relative(0.25),
        .relative(-1),
        .mixed(absolute: 10, relative: 0.25),
        .mixed(absolute: -2, relative: -0.5)
    ]

    @Test("Values describing the same quantity are equal and hash equally")
    func equivalentFormsAreEqual() {
        for forms in Self.equivalentForms {
            for form in forms {
                #expect(form == forms[0])
                #expect(form.hashValue == forms[0].hashValue)
            }
            #expect(Set(forms).count == 1)
        }
    }

    @Test("Values describing different quantities are not equal")
    func differentQuantitiesAreNotEqual() {
        #expect(RelatableValue.absolute(5) != .relative(5))
        #expect(RelatableValue.absolute(5) != .mixed(absolute: 5, relative: 1))
        #expect(RelatableValue.relative(0.25) != .mixed(absolute: 1, relative: 0.25))
    }

    @Test("Adding zero leaves a value unchanged", arguments: samples)
    func addingZeroIsIdentity(value: RelatableValue) {
        #expect(value + .zero == value)
        #expect(.zero + value == value)
        #expect(value - .zero == value)
    }

    @Test("Subtracting a value from itself gives zero", arguments: samples)
    func subtractingSelfGivesZero(value: RelatableValue) {
        #expect(value - value == .zero)
        #expect(value + -value == .zero)
    }

    @Test("Addition is commutative", arguments: samples, samples)
    func additionIsCommutative(lhs: RelatableValue, rhs: RelatableValue) {
        #expect(lhs + rhs == rhs + lhs)
    }

    /// Arithmetic on the value has to agree with arithmetic on what it resolves
    /// to, whichever total it is resolved against.
    @Test("Resolved values match resolving each operand", arguments: samples, samples)
    func resolvedArithmeticMatches(lhs: RelatableValue, rhs: RelatableValue) {
        for total in [CGFloat(0), 1, 40, -12.5] {
            let sum = (lhs + rhs).value(using: total)
            #expect(abs(sum - (lhs.value(using: total) + rhs.value(using: total))) <= 1e-12)

            let difference = (lhs - rhs).value(using: total)
            #expect(
                abs(difference - (lhs.value(using: total) - rhs.value(using: total))) <= 1e-12
            )
        }
    }

    @Test("Scaling multiplies both components", arguments: samples)
    func scalingMultipliesBothComponents(value: RelatableValue) {
        let doubled = value * 2
        #expect(doubled.components.absolute == value.components.absolute * 2)
        #expect(doubled.components.relative == value.components.relative * 2)
        #expect(doubled / 2 == value)
        #expect(value * 0 == .zero)
    }

    @Test("Multiplication and division assignment match their operators")
    func assignmentOperatorsMatch() {
        var value = RelatableValue.mixed(absolute: 10, relative: 0.25)
        value *= 3
        #expect(value == .mixed(absolute: 30, relative: 0.75))
        value /= 3
        #expect(value == .mixed(absolute: 10, relative: 0.25))
    }

    /// The multiplication and division operators are `@_disfavoredOverload` so a
    /// bare literal on the left of a `CGFloat` is never read as a
    /// ``RelatableValue``.
    @Test("A literal times a CGFloat still produces a CGFloat")
    func literalTimesCGFloatStaysScalar() {
        let width: CGFloat = 4
        let scaled: CGFloat = 1 * width
        let halved: CGFloat = 1 / width

        #expect(scaled == 4)
        #expect(halved == 0.25)
    }

    @Test("VectorArithmetic scaling matches multiplication", arguments: samples)
    func vectorArithmeticScaleMatchesMultiplication(value: RelatableValue) {
        var scaled = value
        scaled.scale(by: 1.5)

        #expect(scaled == value * 1.5)
    }

    @Test("Magnitude squared uses both components", arguments: samples)
    func magnitudeSquaredUsesBothComponents(value: RelatableValue) {
        let components = value.components
        let expected = (components.absolute * components.absolute)
            + (components.relative * components.relative)

        #expect(abs(value.magnitudeSquared - expected) <= 1e-12)
    }
}
