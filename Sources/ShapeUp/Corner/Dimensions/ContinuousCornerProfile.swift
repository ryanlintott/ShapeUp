//
//  ContinuousCornerProfile.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-17.
//

import SwiftUI

/// The shape of a continuous rounded corner, independent of any particular corner it's drawn into.
///
/// ## How the shape is defined
///
/// Both kinds of rounded corner are described by how sharply they bend at each point along their length. A circular corner bends at a constant rate the whole way around, which is what makes it part of a circle, and its length is `radius * turnAngle`. A continuous corner instead bends slowly at first, most sharply near the middle, then slowly again at the end. That bending pattern is fixed, and its length is ``arcLengthPerRadiusRadian`` `* radius * turnAngle`.
///
/// Two useful things follow. The pattern starts and ends at zero bend, so the curve leaves and rejoins its straight edges without any sudden change in how sharply it's turning. And how hard it bends depends only on the radius, so a corner looks equally round at every angle; the turn angle only decides how much of the pattern gets used.
///
/// ## Building the curve from that bending pattern
///
/// Everything here is built from ``halfCurvatureSamples`` in four steps:
///
/// 1. Rescale the samples so they add up to one turn (``normalizedCurvatureSamples``).
/// 2. Add them up as you move along the curve to get how much of the total turn is finished at any point (``turnFraction(at:)``).
/// 3. Multiply that fraction by the corner's turn angle to get the direction of travel at that point (``tangent(at:turnAngle:)``).
/// 4. Add up those directions to get position (``offset(at:turnAngle:)``).
///
/// ## Reference frame
///
/// The curve is described starting at the origin, travelling along the positive x axis, with positions measured as a fraction of the curve's total length rather than in points. ``addCurve(to:from:direction:turnAngle:radius:)`` scales, rotates and moves it into place.
internal enum ContinuousCornerProfile {
    /// A position along the reference curve, paired with its direction of travel.
    ///
    /// The offset is a fraction of the curve's total length, so it needs scaling before it means anything in points.
    internal struct Sample {
        let offset: Vector2
        let tangent: Vector2
    }

    /// A point on the curve, already scaled, rotated and moved into a path, paired with the direction of travel at that point.
    private struct PlacedSample {
        let point: CGPoint
        let tangent: Vector2

        /// Returns the point where this sample's line of travel crosses another's.
        ///
        /// Used to find where the straight edge leaving one sample would meet the straight edge arriving at another. A nil value means the two directions are parallel, so they never cross.
        /// - Parameter other: Another sample on the same curve.
        /// - Returns: The point where the two lines cross.
        func tangentIntersection(with other: Self) -> CGPoint? {
            let denominator = tangent.crossProduct(with: other.tangent)
            guard abs(denominator) > 1e-12 else { return nil }

            let tangentScale = (other.point.vector - point.vector)
                .crossProduct(with: other.tangent) / denominator
            return point.moved(tangent * tangentScale)
        }
    }

    /// How sharply the corner bends, sampled at evenly spaced positions from the start of the curve to its midpoint.
    ///
    /// Fitted to SwiftUI's continuous corner as it is actually *drawn*, measured from rendered pixels alone by `ContinuousCornerRasterProbe` in the test target, which renders the shape on its own and reads its coverage. Replacing these with a different fit is all it takes to change the corner's shape.
    ///
    /// The first entry is zero because the curve starts out not bending at all, which is what lets it meet its straight edge smoothly. Values rise toward the middle of the curve, where it bends most sharply.
    ///
    /// The pattern is symmetric, so only the first half is stored; the second half is mirrored from it in ``normalizedCurvatureSamples``. Only the relative size of these numbers matters, since ``normalizedCurvatureSamples`` divides their scale back out.
    ///
    /// ## Why these are fitted rather than read off a path
    ///
    /// `RoundedRectangle(style: .continuous).path(in:).forEach(_:)` returns all the elements in the path, but those elements don't match the drawn path exactly. Deriving curvature from them directly was tried and the result was worse.
    ///
    /// Those elements are exact about the wrong shape, sitting roughly 0.0015 radii from what SwiftUI rasterises. Their curvature also jumps by a third at each of the two interior joins, which a run of evenly spaced samples joined by straight ramps cannot represent; sampling across a jump rounds it into a ramp. A profile derived that way misses even the path it came from by about 0.006 radii, four times further out than this fit is from the rendered shape.
    ///
    /// - Note: The dip at the midpoint is not a feature of Apple's shape, whose own curvature is flat there. It is this profile absorbing those same curvature jumps, and removing it makes the rendered match worse rather than better.
    private static let halfCurvatureSamples: [CGFloat] = [
        0,
        0.120575633188881,
        0.169925673352087,
        0.549900588347802,
        0.87378996951606,
        1.75935447654183,
        2.0743885519563,
        1.96876302846267,
        1.51959808259975
    ]

    /// ``halfCurvatureSamples`` mirrored into a full pattern, then rescaled so the whole thing adds up to exactly one turn.
    ///
    /// The area under these samples is found by treating them as a series of straight ramps and adding up the trapezoids beneath: each pair of neighbours contributes `(first + second) / 2 * width`. Dividing every sample by that total is what makes ``turnFraction(at:)`` able to just add samples up, instead of adding them up and then dividing by a total each time.
    private static let normalizedCurvatureSamples: [CGFloat] = {
        let mirrored = halfCurvatureSamples + halfCurvatureSamples.dropLast().reversed()
        let intervalLength = 1 / CGFloat(mirrored.count - 1)
        let total = zip(mirrored, mirrored.dropFirst())
            .reduce(0) { $0 + (($1.0 + $1.1) * intervalLength / 2) }
        return mirrored.map { $0 / total }
    }()

    /// The number of evenly spaced gaps between curvature samples.
    private static let intervalCount: Int = normalizedCurvatureSamples.count - 1

    /// How much of the total turn is finished at each curvature sample.
    ///
    /// A running total of the trapezoid areas described in ``normalizedCurvatureSamples``, so this starts at 0 and ends at 1. Working these out once up front means ``turnFraction(at:)`` only has to handle the single gap its parameter falls inside, rather than adding up everything before it every time.
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

    /// How far SwiftUI's continuous 90-degree corner reaches along each edge, per unit of nominal radius.
    ///
    /// A single measured number, and the only thing tying this curve to SwiftUI's. A circular 90-degree corner reaches exactly one radius along each edge, so this says SwiftUI's continuous corner reaches about 53% farther.
    private static let swiftUICutLengthPerRadius: CGFloat = 1.5286649465560913

    /// How far the reference curve reaches along its edge at 90 degrees, as a fraction of the curve's own length.
    ///
    /// Needed to convert ``swiftUICutLengthPerRadius``, which is measured against the edge, into ``arcLengthPerRadiusRadian``, which is measured along the curve.
    private static let rightAngleCutLengthPerArcLength: CGFloat =
        integrate(from: 0, to: 1) { cos((.pi / 2) * turnFraction(at: $0)) }

    /// The length of a continuous corner, per unit of radius, per radian turned.
    ///
    /// A circular corner is `radius * turnAngle` long. A continuous corner uses that same rule scaled by this constant, which is what keeps it bending as hard as a circular corner of the same radius no matter what angle it's drawn at.
    ///
    /// It's derived so that a 90-degree corner ends up reaching exactly ``swiftUICutLengthPerRadius`` along its edges, matching SwiftUI. It's also what ``cutLengthMultiplier(turnAngle:)`` settles on as a corner flattens out toward straight.
    internal static let arcLengthPerRadiusRadian: CGFloat =
        swiftUICutLengthPerRadius
        / ((.pi / 2) * rightAngleCutLengthPerArcLength)

    /// Returns how much of the corner's total turn is finished at a position along the curve.
    ///
    /// Between two curvature samples the bend is treated as ramping evenly from one to the next, so the area under that ramp partway across is `start * distance + rise * distance * distance / 2`. Adding that to the running total already banked at the previous sample gives the answer without touching any of the earlier samples.
    /// - Parameter parameter: Position along the curve, as a fraction of its total length.
    /// - Returns: A fraction from zero at the start of the curve to one at its end.
    internal static func turnFraction(at parameter: CGFloat) -> CGFloat {
        let scaled = min(max(parameter, 0), 1) * CGFloat(intervalCount)
        let index = min(Int(scaled), intervalCount - 1)
        let localParameter = scaled - CGFloat(index)

        let startCurvature = normalizedCurvatureSamples[index]
        let curvatureRise = normalizedCurvatureSamples[index + 1] - startCurvature
        let localTurn = (startCurvature * localParameter)
            + (curvatureRise * localParameter * localParameter / 2)

        return sampledTurnFractions[index] + (localTurn / CGFloat(intervalCount))
    }

    /// Returns the direction of travel at a position along the reference curve.
    ///
    /// The curve has turned `turnAngle * turnFraction` from its starting direction by this point, so this is just that angle written as a unit vector.
    /// - Parameters:
    ///   - parameter: Position along the curve, as a fraction of its total length.
    ///   - turnAngle: Total angle the curve turns through. Negative values turn clockwise.
    /// - Returns: A direction of travel with a length of one.
    internal static func tangent(
        at parameter: CGFloat,
        turnAngle: CGFloat
    ) -> Vector2 {
        let direction = turnAngle * turnFraction(at: parameter)
        return Vector2(dx: cos(direction), dy: sin(direction))
    }

    /// Returns how far the curve has moved from its starting point by a position along it.
    ///
    /// Found by adding up the directions of travel from the start of the curve up to this point.
    /// - Parameters:
    ///   - parameter: Position along the curve, as a fraction of its total length.
    ///   - turnAngle: Total angle the curve turns through. Negative values turn clockwise.
    /// - Returns: An offset measured as a fraction of the curve's total length.
    internal static func offset(
        at parameter: CGFloat,
        turnAngle: CGFloat
    ) -> Vector2 {
        integrate(from: 0, to: min(max(parameter, 0), 1)) {
            tangent(at: $0, turnAngle: turnAngle)
        }
    }

    /// Returns evenly spaced positions and directions of travel along the reference curve.
    ///
    /// Positions along this curve are measured by distance travelled, so evenly spaced parameters really do carve it into equal-length pieces.
    /// - Parameters:
    ///   - count: How many equal pieces to divide the curve into. One more sample than this is returned, since both ends are included.
    ///   - turnAngle: Total angle the curve turns through. Negative values turn clockwise.
    /// - Returns: Offsets, as fractions of the curve's total length, each paired with a direction of travel.
    internal static func samples(
        count: Int,
        turnAngle: CGFloat
    ) -> [Sample] {
        let spanLength = 1 / CGFloat(count)
        var offset = Vector2.zero
        var samples = [Sample(offset: offset, tangent: tangent(at: 0, turnAngle: turnAngle))]

        // Carry the running offset forward one piece at a time so the curve is
        // only added up once overall, rather than from the start for each sample.
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

    /// Returns how far a continuous corner reaches along its edges, as a multiple of how far a circular corner of the same radius would.
    ///
    /// Always greater than one: a continuous corner starts curving away from the edge sooner. The multiple grows as the corner flattens out, from about 1.01 at a hairpin up to ``arcLengthPerRadiusRadian`` at straight.
    /// - Parameter turnAngle: Total angle the corner turns through, from zero at a straight corner up to 180 degrees at a hairpin.
    /// - Returns: A multiple of the circular corner's edge length.
    internal static func cutLengthMultiplier(turnAngle: CGFloat) -> CGFloat {
        // Both corners reach as far as the point where their two edges would
        // meet. For a circular corner that distance works out to
        // `tan(turnAngle / 2)`; for this one it's
        // `(the sum below) / sin(turnAngle)`.
        //
        // Dividing one by the other leaves `sin(turnAngle) * tan(turnAngle / 2)`
        // on the bottom, which is the same as `2 * sin(turnAngle / 2) ^ 2`.
        // Both that and the sum on top shrink to nothing at a straight corner,
        // which would be a division of zero by zero. Writing both in terms of
        // `sinc` pulls that shrinking factor out of each so it cancels, leaving
        // a result that stays accurate all the way to both extremes.
        let remainingTurn = integrate(from: 0, to: 1) {
            let remaining = 1 - turnFraction(at: $0)
            return remaining * sinc(turnAngle * remaining)
        }
        let halfTurnSinc = sinc(turnAngle / 2)

        return arcLengthPerRadiusRadian * 2 * remainingTurn
            / (halfTurnSinc * halfTurnSinc)
    }

    /// Adds a continuous corner curve to a path, as a chain of cubic curves.
    ///
    /// ## Choosing the points
    ///
    /// The curve is sampled at `segmentCount + 1` evenly spaced positions, and one cubic curve is drawn between each neighbouring pair. Every cubic starts and ends exactly on the real curve, heading in exactly the right direction at both ends, so the only error is a slight drift in between.
    ///
    /// ## Choosing the control points
    ///
    /// A cubic curve leaves its start point heading straight at its first control point, and arrives at its end point coming straight from its second. How far away those control points sit decides how strongly it commits to that direction. Placing each one a third of the piece's length away is what makes the cubic's speed match the real curve's at both ends, and a third is exactly right because a cubic's rate of change at its ends is three times the gap to the neighbouring control point.
    ///
    /// ## Keeping the ends flat
    ///
    /// The bending pattern starts and ends at zero, so the finished corner has to meet its straight edges without any sudden bend. A cubic bends at its start point only if its first two control points sit off to one side of it, so putting both of them on the straight edge instead guarantees a flat join. The second control point is moved to where the two ends' directions of travel cross, which is the one spot on that edge that still lets the piece arrive pointing the right way.
    /// - Parameters:
    ///   - path: The path the curve is added to.
    ///   - start: The point where the curve begins.
    ///   - direction: The direction of travel at the start of the curve.
    ///   - turnAngle: The angle the curve turns through. Negative values turn clockwise.
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
        // A third of one piece's length, as described above.
        let controlLength = arcLength / CGFloat(segmentCount * 3)

        for index in 0..<segmentCount {
            let start = placedSamples[index]
            let end = placedSamples[index + 1]
            var control1 = start.point.moved(start.tangent * controlLength)
            var control2 = end.point.moved(-end.tangent * controlLength)

            if index == 0 {
                control2 = start.tangentIntersection(with: end) ?? control2
            } else if index == segmentCount - 1 {
                control1 = start.tangentIntersection(with: end) ?? control1
            }

            path.addCurve(to: end.point, control1: control1, control2: control2)
        }
    }

    /// Returns `sin(x) / x`, which would be zero divided by zero at `x = 0` but actually settles on 1.
    private static func sinc(_ x: CGFloat) -> CGFloat {
        // Near zero, `sin(x)` is very close to `x - x * x * x / 6`, so dividing
        // through by x gives this. Using it avoids dividing two numbers that are
        // both shrinking toward zero, and gives an exact answer at zero itself.
        guard abs(x) > 1e-4 else { return 1 - (x * x / 6) }
        return sin(x) / x
    }

    /// Adds up a function across part of the curve.
    ///
    /// The span is chopped at every curvature sample first, because ``gaussLegendre(from:to:value:)`` assumes what it's adding up is smooth, and the bending pattern has corners in it where one ramp meets the next.
    /// - Parameters:
    ///   - lowerBound: Position along the curve to start from.
    ///   - upperBound: Position along the curve to stop at.
    ///   - value: The function being added up.
    /// - Returns: The total across the span.
    private static func integrate<Value: VectorArithmetic>(
        from lowerBound: CGFloat,
        to upperBound: CGFloat,
        value: (CGFloat) -> Value
    ) -> Value {
        var result = Value.zero
        var lower = lowerBound

        while lower < upperBound {
            // The next curvature sample past the lower bound. Rounding down and
            // adding one always moves forward, so this can't get stuck.
            let nextSample = (floor(lower * CGFloat(intervalCount)) + 1)
                / CGFloat(intervalCount)
            let upper = min(nextSample, upperBound)
            result += gaussLegendre(from: lower, to: upper, value: value)
            lower = upper
        }
        return result
    }

    /// Where to sample when adding up a smooth function, given as positions across a span running from -1 to 1.
    ///
    /// Sampling at these specific spots rather than at evenly spaced ones is what makes eight samples enough: the result is exact for anything that can be written as a polynomial up to degree 15, and extremely close for smooth functions generally. This is standard Gauss-Legendre integration.
    ///
    /// ## Regenerating these
    ///
    /// The positions are the eight values where the eighth Legendre polynomial crosses zero. Those polynomials are built up one at a time:
    ///
    /// ```
    /// P(0, x) = 1
    /// P(1, x) = x
    /// P(n + 1, x) = ((2n + 1) * x * P(n, x) - n * P(n - 1, x)) / (n + 1)
    /// ```
    ///
    /// with slope
    ///
    /// ```
    /// slope(n, x) = n * (x * P(n, x) - P(n - 1, x)) / (x * x - 1)
    /// ```
    ///
    /// To find crossing number `k` of `n`, start at `cos(pi * (k - 0.25) / (n + 0.5))` and repeatedly replace `x` with `x - P(n, x) / slope(n, x)` until it stops moving.
    ///
    /// `ContinuousCornerProfileIntegrationTests` implements exactly this for any count and checks its results against the values below, so raising the sample count is a matter of running it and pasting in what it produces.
    internal static let integrationNodes: [CGFloat] = [
        -0.9602898564975363,
        -0.7966664774136267,
        -0.525532409916329,
        -0.1834346424956498,
        0.1834346424956498,
        0.525532409916329,
        0.7966664774136267,
        0.9602898564975363
    ]

    /// How much each position in ``integrationNodes`` counts toward the total.
    ///
    /// Once a position `x` is known, its share is `2 / ((1 - x * x) * slope(n, x) * slope(n, x))`, using the same slope formula given in ``integrationNodes``. Positions nearer the middle of the span count for more. The shares always add up to 2, the width of the -1 to 1 span they cover.
    internal static let integrationWeights: [CGFloat] = [
        0.1012285362903763,
        0.2223810344533745,
        0.3137066458778873,
        0.362683783378362,
        0.362683783378362,
        0.3137066458778873,
        0.2223810344533745,
        0.1012285362903763
    ]

    /// Adds up a function across a span where it's smooth, by sampling it at eight carefully chosen spots.
    ///
    /// ``integrationNodes`` and ``integrationWeights`` are set up for a span running from -1 to 1, so each is stretched and shifted onto the real span first, and the total is scaled by half the span's width to match.
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
