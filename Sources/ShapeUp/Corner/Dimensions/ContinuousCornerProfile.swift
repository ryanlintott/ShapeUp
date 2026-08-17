//
//  ContinuousCornerProfile.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-17.
//

import SwiftUI

/// The intrinsic shape of a continuous rounded corner.
///
/// A continuous corner is defined the same way a circular corner is: by its
/// curvature. A circular corner holds curvature at `1 / radius` across an arc
/// length of `radius * turnAngle`. A continuous corner holds a fixed curvature
/// *profile*, scaled by `1 / radius`, across an arc length of
/// ``arcLengthPerRadiusRadian`` `* radius * turnAngle`.
///
/// Two properties follow from that definition. The profile starts and ends at
/// zero curvature, so the curve joins its edges without a curvature jump. Its
/// magnitude depends only on the radius, so a corner keeps the same visual
/// radius at every angle while the turn angle decides how much of the profile's
/// arc length is used.
///
/// The curve is described in a reference frame where it starts at the origin
/// travelling along the positive x axis, is measured by arc length as a
/// fraction of its total, and has unit speed.
internal enum ContinuousCornerProfile {
    /// An offset paired with the unit tangent at that offset.
    internal struct Sample {
        let offset: Vector2
        let tangent: Vector2
    }

    /// A point on the curve, placed and rotated into a path, paired with the
    /// tangent at that point.
    private struct PlacedSample {
        let point: CGPoint
        let tangent: Vector2

        /// Returns the point where this sample's tangent line crosses another's.
        ///
        /// A nil value means the two tangents are parallel.
        /// - Parameter other: Another sample on the same curve.
        /// - Returns: The point where the two tangent lines cross.
        func tangentIntersection(with other: Self) -> CGPoint? {
            let denominator = tangent.crossProduct(with: other.tangent)
            guard abs(denominator) > 1e-12 else { return nil }

            let tangentScale = (other.point.vector - point.vector)
                .crossProduct(with: other.tangent) / denominator
            return point.moved(tangent * tangentScale)
        }
    }

    /// Curvature of the reference profile at evenly spaced positions from the
    /// start of the curve to its midpoint.
    ///
    /// Fitted to an unconstrained 128-point SwiftUI corner rendered at 8x
    /// across four quarter-pixel phases. The profile is symmetric, so these
    /// samples are mirrored to describe the second half of the curve.
    ///
    /// Only the shape of these samples matters. Their scale is divided out by
    /// ``normalizedCurvatureSamples``.
    private static let halfCurvatureSamples: [CGFloat] = [
        0,
        0.126143061267713,
        0.130089752883054,
        0.612090852614914,
        0.877096759961826,
        1.5369790112525,
        2.0743885519563,
        1.77042874091634,
        1.72155742814922
    ]

    /// The mirrored curvature samples, rescaled so that their integral across
    /// the curve is one.
    ///
    /// Normalizing here makes ``turnFraction(at:)`` a direct integral of these
    /// samples rather than a ratio of two integrals.
    private static let normalizedCurvatureSamples: [CGFloat] = {
        let mirrored = halfCurvatureSamples + halfCurvatureSamples.dropLast().reversed()
        let intervalLength = 1 / CGFloat(mirrored.count - 1)
        let total = zip(mirrored, mirrored.dropFirst())
            .reduce(0) { $0 + (($1.0 + $1.1) * intervalLength / 2) }
        return mirrored.map { $0 / total }
    }()

    /// The number of evenly spaced intervals between curvature samples.
    private static let intervalCount: Int = normalizedCurvatureSamples.count - 1

    /// The turn fraction reached at each curvature sample.
    ///
    /// Precomputing these means ``turnFraction(at:)`` only has to integrate
    /// across the single interval containing its parameter.
    private static let sampledTurnFractions: [CGFloat] = {
        var fractions: [CGFloat] = [0]
        for index in 0..<intervalCount {
            let averageCurvature = (
                normalizedCurvatureSamples[index]
                + normalizedCurvatureSamples[index + 1]
            ) / 2
            fractions.append(
                fractions[index] + (averageCurvature / CGFloat(intervalCount))
            )
        }
        return fractions
    }()

    /// Edge length used by SwiftUI's continuous 90-degree corner, per unit of
    /// nominal radius.
    ///
    /// This is the one measured value the profile is calibrated against.
    private static let swiftUICutLengthPerRadius: CGFloat = 1.5286649465560913

    /// Cut length of the reference curve at 90 degrees, as a fraction of its
    /// arc length.
    private static let rightAngleCutLengthPerArcLength: CGFloat =
        integrate(from: 0, to: 1) { cos((.pi / 2) * turnFraction(at: $0)) }

    /// Arc length of a continuous corner per unit of radius per radian of turn.
    ///
    /// A circular corner has an arc length of `radius * turnAngle`. A
    /// continuous corner uses the same law scaled by this constant, which is
    /// what holds its curvature, and so its visual radius, steady across
    /// angles. It is also the limit of ``cutLengthMultiplier(turnAngle:)`` at a
    /// straight corner.
    internal static let arcLengthPerRadiusRadian: CGFloat =
        swiftUICutLengthPerRadius
        / ((.pi / 2) * rightAngleCutLengthPerArcLength)

    /// Returns the fraction of the total turn completed at a position along the
    /// curve.
    /// - Parameter parameter: Position along the curve as a fraction of its arc
    ///   length.
    /// - Returns: The fraction of the total turn completed, from zero at the
    ///   start of the curve to one at its end.
    internal static func turnFraction(at parameter: CGFloat) -> CGFloat {
        let scaled = min(max(parameter, 0), 1) * CGFloat(intervalCount)
        let index = min(Int(scaled), intervalCount - 1)
        let localParameter = scaled - CGFloat(index)

        // Integrate the linear curvature ramp across the remaining part of the
        // interval, in the interval's own local parameter.
        let startCurvature = normalizedCurvatureSamples[index]
        let curvatureRise = normalizedCurvatureSamples[index + 1] - startCurvature
        let localTurn = (startCurvature * localParameter)
            + (curvatureRise * localParameter * localParameter / 2)

        return sampledTurnFractions[index] + (localTurn / CGFloat(intervalCount))
    }

    /// Returns the unit tangent of the reference curve at a position along it.
    /// - Parameters:
    ///   - parameter: Position along the curve as a fraction of its arc length.
    ///   - turnAngle: Total angle the curve turns through. Negative values turn
    ///     clockwise.
    /// - Returns: The unit tangent of the reference curve.
    internal static func tangent(
        at parameter: CGFloat,
        turnAngle: CGFloat
    ) -> Vector2 {
        let direction = turnAngle * turnFraction(at: parameter)
        return Vector2(dx: cos(direction), dy: sin(direction))
    }

    /// Returns the offset from the start of the reference curve to a position
    /// along it.
    /// - Parameters:
    ///   - parameter: Position along the curve as a fraction of its arc length.
    ///   - turnAngle: Total angle the curve turns through. Negative values turn
    ///     clockwise.
    /// - Returns: An offset as a fraction of the curve's arc length.
    internal static func offset(
        at parameter: CGFloat,
        turnAngle: CGFloat
    ) -> Vector2 {
        integrate(from: 0, to: min(max(parameter, 0), 1)) {
            tangent(at: $0, turnAngle: turnAngle)
        }
    }

    /// Returns evenly spaced offsets and unit tangents along the reference
    /// curve.
    ///
    /// The curve has unit speed, so evenly spaced parameters divide it into
    /// equal arc lengths.
    /// - Parameters:
    ///   - count: The number of equal spans to divide the curve into. One more
    ///     sample than this is returned.
    ///   - turnAngle: Total angle the curve turns through. Negative values turn
    ///     clockwise.
    /// - Returns: Offsets, as fractions of the curve's arc length, paired with
    ///   unit tangents.
    internal static func samples(
        count: Int,
        turnAngle: CGFloat
    ) -> [Sample] {
        let spanLength = 1 / CGFloat(count)
        var offset = Vector2.zero
        var samples = [Sample(offset: offset, tangent: tangent(at: 0, turnAngle: turnAngle))]

        // Accumulate one span at a time so the whole curve is integrated once.
        for index in 0..<count {
            let parameter = CGFloat(index + 1) * spanLength
            offset += integrate(from: CGFloat(index) * spanLength, to: parameter) {
                tangent(at: $0, turnAngle: turnAngle)
            }
            samples.append(
                Sample(offset: offset, tangent: tangent(at: parameter, turnAngle: turnAngle))
            )
        }
        return samples
    }

    /// Returns the edge length used by a continuous corner as a multiple of the
    /// edge length used by a circular corner with the same nominal radius.
    /// - Parameter turnAngle: Total angle the corner turns through, from zero
    ///   at a straight corner to 180 degrees at a zero-degree corner.
    /// - Returns: A multiple of the circular corner's edge length.
    internal static func cutLengthMultiplier(turnAngle: CGFloat) -> CGFloat {
        // The corner point is where the two edge lines meet, which puts the
        // continuous cut length at `∫ sin(turn * (1 - turnFraction)) / sin(turn)`
        // and the circular cut length at `tan(turn / 2)`. Since
        // `sin(turn) * tan(turn / 2)` is `2 * sin(turn / 2) ^ 2`, writing both
        // with `sinc` cancels the removable singularities at a straight corner
        // and at a zero-degree corner.
        let remainingTurn = integrate(from: 0, to: 1) {
            let remaining = 1 - turnFraction(at: $0)
            return remaining * sinc(turnAngle * remaining)
        }
        let halfTurnSinc = sinc(turnAngle / 2)

        return arcLengthPerRadiusRadian * 2 * remainingTurn
            / (halfTurnSinc * halfTurnSinc)
    }

    /// Adds a continuous corner curve to a path.
    ///
    /// The curve begins at `start`, travels initially in `direction`, and
    /// turns through `turnAngle` while holding a fixed nominal `radius`. It's
    /// approximated with evenly spaced cubic curves.
    /// - Parameters:
    ///   - path: The path the curve is added to.
    ///   - start: The point where the curve begins.
    ///   - direction: The direction of travel at the start of the curve.
    ///   - turnAngle: The signed angle the curve turns through. Negative
    ///     values turn clockwise.
    ///   - radius: The nominal radius of the curve.
    internal static func addCurve(
        to path: inout Path,
        from start: CGPoint,
        direction: Angle,
        turnAngle: CGFloat,
        radius: CGFloat
    ) {
        let segmentCount = 16
        let arcLength = arcLengthPerRadiusRadian * radius * abs(turnAngle)
        let placedSamples = samples(count: segmentCount, turnAngle: turnAngle).map {
            PlacedSample(
                point: start.moved(($0.offset * arcLength).rotated(direction)),
                tangent: $0.tangent.rotated(direction)
            )
        }
        // A cubic matching the curve's tangents spans a third of a segment.
        let controlLength = arcLength / CGFloat(segmentCount * 3)

        for index in 0..<segmentCount {
            let start = placedSamples[index]
            let end = placedSamples[index + 1]
            var control1 = start.point.moved(start.tangent * controlLength)
            var control2 = end.point.moved(-end.tangent * controlLength)

            // The profile starts and ends with zero curvature. Placing both
            // control points of the first and last segments on their edge
            // line carries that through to the cubic, so the corner meets
            // its edges without a curvature jump.
            if index == 0 {
                control2 = start.tangentIntersection(with: end) ?? control2
            } else if index == segmentCount - 1 {
                control1 = start.tangentIntersection(with: end) ?? control1
            }

            path.addCurve(to: end.point, control1: control1, control2: control2)
        }
    }

    /// Returns `sin(x) / x`, which is continuous at zero.
    private static func sinc(_ x: CGFloat) -> CGFloat {
        // Below this magnitude the series is both cheaper and more accurate
        // than dividing two values that are approaching zero together.
        guard abs(x) > 1e-4 else { return 1 - (x * x / 6) }
        return sin(x) / x
    }

    /// Integrates a function across a span of the curve.
    ///
    /// The span is split at curvature samples so that every panel covers a
    /// single smooth piece of the profile.
    /// - Parameters:
    ///   - lowerBound: Position along the curve where integration starts.
    ///   - upperBound: Position along the curve where integration ends.
    ///   - value: The function to integrate.
    /// - Returns: The integral of the function across the span.
    private static func integrate<Value: VectorArithmetic>(
        from lowerBound: CGFloat,
        to upperBound: CGFloat,
        value: (CGFloat) -> Value
    ) -> Value {
        var result = Value.zero
        var lower = lowerBound

        while lower < upperBound {
            // The next curvature sample above the lower bound. Adding one to
            // the floored index always advances, so the loop makes progress.
            let nextSample = (floor(lower * CGFloat(intervalCount)) + 1)
                / CGFloat(intervalCount)
            let upper = min(nextSample, upperBound)
            result += gaussLegendre(from: lower, to: upper, value: value)
            lower = upper
        }
        return result
    }

    /// Nodes and weights for eight-point Gauss-Legendre integration.
    private static let integrationNodes: [CGFloat] = [
        -0.9602898564975363,
        -0.7966664774136267,
        -0.525532409916329,
        -0.1834346424956498,
        0.1834346424956498,
        0.525532409916329,
        0.7966664774136267,
        0.9602898564975363
    ]

    private static let integrationWeights: [CGFloat] = [
        0.1012285362903763,
        0.2223810344533745,
        0.3137066458778873,
        0.362683783378362,
        0.362683783378362,
        0.3137066458778873,
        0.2223810344533745,
        0.1012285362903763
    ]

    /// Integrates a function across a span where it is smooth.
    private static func gaussLegendre<Value: VectorArithmetic>(
        from lowerBound: CGFloat,
        to upperBound: CGFloat,
        value: (CGFloat) -> Value
    ) -> Value {
        let midpoint = (lowerBound + upperBound) / 2
        let halfSpan = (upperBound - lowerBound) / 2

        return zip(integrationNodes, integrationWeights)
            .reduce(Value.zero) { total, node in
                total + value(midpoint + (halfSpan * node.0)).scaled(by: node.1)
            }
            .scaled(by: halfSpan)
    }
}
